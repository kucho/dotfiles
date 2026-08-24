#!/usr/bin/env bash
# mise mysql postinstall:
# 1) Linux-only: fix Oracle client ncurses soname on distros that only ship libncursesw
# 2) Initialize the durable datadir once
# 3) Create a superuser + database for the current OS user (macOS + Linux)
set -euo pipefail

# Portable realpath: GNU readlink -f is not available on macOS/BSD.
resolve_path() {
  local target="$1"
  if command -v realpath >/dev/null 2>&1; then
    realpath "$target"
    return
  fi
  if readlink -f "$target" >/dev/null 2>&1; then
    readlink -f "$target"
    return
  fi
  local dir base
  while [[ -L "$target" ]]; do
    dir="$(cd "$(dirname "$target")" && pwd -P)"
    target="$(readlink "$target")"
    [[ "$target" != /* ]] && target="${dir}/${target}"
  done
  dir="$(cd "$(dirname "$target")" && pwd -P)"
  base="$(basename "$target")"
  printf '%s/%s\n' "$dir" "$base"
}

root="${MISE_TOOL_INSTALL_PATH:?}"
if [[ -L "$root" ]]; then
  root="$(resolve_path "$root")"
fi

basedir="$root"
datadir="${MYSQL_DATADIR:-$HOME/.local/share/mysql/data}"
mysqld="${basedir}/bin/mysqld"
mysql="${basedir}/bin/mysql"
mysqladmin="${basedir}/bin/mysqladmin"
os_user="${MYSQL_OS_USER:-${USER:-$(id -un)}}"
socket="${MYSQL_UNIX_PORT:-/tmp/mysql.sock}"
marker="${datadir}/.mise-os-user-provisioned"

sql_string() {
  printf "%s" "${1//\'/\'\'}"
}

sql_ident() {
  printf "%s" "${1//\`/\`\`}"
}

# Linux-only. Oracle's linux client NEEDs libncurses.so.6 via RUNPATH
# $ORIGIN/../lib/private. Arch/CachyOS only ship libncursesw.so.6.
# macOS official tarballs do not use this ELF soname path; no-op there.
fix_ncurses_client() {
  local private_lib ncurses_src candidate

  [[ "$(uname -s)" == Linux ]] || return 0

  private_lib="${root}/lib/private"
  [[ -d "$private_lib" ]] || return 0
  [[ -e "${private_lib}/libncurses.so.6" ]] && return 0

  ncurses_src=""
  for candidate in \
    /usr/lib/libncursesw.so.6 \
    /usr/lib/libncurses.so.6 \
    /lib/x86_64-linux-gnu/libncurses.so.6 \
    /lib/x86_64-linux-gnu/libncursesw.so.6 \
    /lib/aarch64-linux-gnu/libncurses.so.6 \
    /lib/aarch64-linux-gnu/libncursesw.so.6
  do
    if [[ -e "$candidate" ]]; then
      ncurses_src="$candidate"
      break
    fi
  done

  [[ -n "$ncurses_src" ]] || return 0
  ln -sfn "$ncurses_src" "${private_lib}/libncurses.so.6"
}

wait_for_mysql() {
  local i
  for i in $(seq 1 60); do
    if "$mysqladmin" --socket="$socket" -uroot ping &>/dev/null; then
      return 0
    fi
    sleep 0.25
  done
  echo "timed out waiting for mysqld to accept connections" >&2
  return 1
}

mysql_already_up() {
  "$mysqladmin" --socket="$socket" -uroot ping &>/dev/null
}

initialize_datadir() {
  mkdir -p "$(dirname "$datadir")"
  if [[ -d "${datadir}/mysql" ]]; then
    return 0
  fi
  if [[ ! -x "$mysqld" ]]; then
    echo "mysqld not found at ${mysqld}" >&2
    return 1
  fi
  mkdir -p "$datadir"
  "$mysqld" \
    --initialize-insecure \
    --basedir="$basedir" \
    --datadir="$datadir"
}

provision_os_user() {
  local user_lit db_ident started_tmp=0 tmp_log pid
  local localhost_auth plugin_sql=""

  if [[ -z "$os_user" || "$os_user" == *$'\n'* ]]; then
    echo "refusing to provision MySQL user from empty/invalid OS username" >&2
    return 1
  fi

  if [[ -f "$marker" ]]; then
    return 0
  fi

  user_lit="$(sql_string "$os_user")"
  db_ident="$(sql_ident "$os_user")"

  if [[ "$(uname -s)" == Linux ]]; then
    # Peer-cred auth over the unix socket: `mysql` works with no password.
    localhost_auth="IDENTIFIED WITH auth_socket"
    plugin_sql="INSTALL PLUGIN auth_socket SONAME 'auth_socket.so';"
  else
    # auth_socket is Linux-only; macOS gets an empty-password local superuser.
    localhost_auth="IDENTIFIED BY ''"
  fi

  if ! mysql_already_up; then
    tmp_log="$(mktemp)"
    started_tmp=1
    if [[ "$(uname -s)" == Linux ]]; then
      "$mysqld" \
        --basedir="$basedir" \
        --datadir="$datadir" \
        --bind-address=127.0.0.1 \
        --socket="$socket" \
        --plugin-load-add=auth_socket=auth_socket.so \
        >"$tmp_log" 2>&1 &
    else
      "$mysqld" \
        --basedir="$basedir" \
        --datadir="$datadir" \
        --bind-address=127.0.0.1 \
        --socket="$socket" \
        >"$tmp_log" 2>&1 &
    fi
    pid=$!

    cleanup_tmp() {
      if [[ "$started_tmp" -eq 1 ]] && kill -0 "$pid" 2>/dev/null; then
        "$mysqladmin" --socket="$socket" -uroot shutdown &>/dev/null || kill "$pid" 2>/dev/null || true
        wait "$pid" 2>/dev/null || true
      fi
      [[ -n "${tmp_log:-}" ]] && rm -f "$tmp_log"
    }
    trap cleanup_tmp EXIT
    wait_for_mysql
  fi

  if [[ -n "$plugin_sql" ]]; then
    # Already-installed plugin is fine on reinstall/upgrade.
    "$mysql" --socket="$socket" -uroot -e "$plugin_sql" &>/dev/null || true
  fi

  "$mysql" --socket="$socket" -uroot <<SQL
CREATE USER IF NOT EXISTS '${user_lit}'@'localhost' ${localhost_auth};
CREATE USER IF NOT EXISTS '${user_lit}'@'127.0.0.1' IDENTIFIED BY '';
CREATE DATABASE IF NOT EXISTS \`${db_ident}\`;
GRANT ALL PRIVILEGES ON *.* TO '${user_lit}'@'localhost' WITH GRANT OPTION;
GRANT ALL PRIVILEGES ON *.* TO '${user_lit}'@'127.0.0.1' WITH GRANT OPTION;
FLUSH PRIVILEGES;
SQL

  touch "$marker"

  if [[ "$started_tmp" -eq 1 ]]; then
    "$mysqladmin" --socket="$socket" -uroot shutdown
    wait "$pid" 2>/dev/null || true
    trap - EXIT
    rm -f "$tmp_log"
  fi
}

fix_ncurses_client
initialize_datadir
provision_os_user

#!/usr/bin/env bash
# mise postgres postinstall:
# 1) Initialize a durable datadir outside the install prefix
# 2) Trust every local connection, so no password and no user restriction
# 3) Ensure superuser `postgres` plus the current OS user (macOS + Linux)
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
datadir="${PGDATA:-$HOME/.local/share/postgres/data}"
confdir="$(dirname "$datadir")"
hba="${POSTGRES_HBA:-$confdir/pg_hba.conf}"
socket_dir="${POSTGRES_SOCKET_DIR:-/tmp}"
os_user="${POSTGRES_OS_USER:-${USER:-$(id -un)}}"

# Conda prefixes (the default mise backend) keep libs next to the binaries.
# A raw exec from launchd/systemd does not activate the prefix.
export LD_LIBRARY_PATH="${basedir}/lib${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
if [[ "$(uname -s)" == Darwin ]]; then
  export DYLD_LIBRARY_PATH="${basedir}/lib${DYLD_LIBRARY_PATH:+:$DYLD_LIBRARY_PATH}"
fi

find_bin() {
  local name="$1"
  local candidate
  for candidate in "${basedir}/bin/${name}" "${basedir}/pgsql/bin/${name}"; do
    if [[ -x "$candidate" ]]; then
      printf '%s\n' "$candidate"
      return 0
    fi
  done
  echo "${name} not found under ${basedir}" >&2
  return 1
}

sql_literal() {
  printf '%s' "${1//\'/\'\'}"
}

sql_ident() {
  printf '%s' "${1//\"/\"\"}"
}

write_hba() {
  mkdir -p "$confdir"
  cat >"$hba" <<'EOF'
# Local dev only. The server listens on loopback; nothing else can connect.
# trust: any local OS user can connect as any role, with no password.
# Same on Linux and macOS, including when the OS user is postgres.
local   all   all                 trust
host    all   all   127.0.0.1/32  trust
host    all   all   ::1/128       trust
EOF
  chmod 600 "$hba"
}

postgres_already_up() {
  "$pg_isready" -h "$socket_dir" -q
}

wait_for_postgres() {
  local i
  for i in $(seq 1 60); do
    if postgres_already_up; then
      return 0
    fi
    sleep 0.5
  done
  echo "timed out waiting for postgres to accept connections" >&2
  return 1
}

initialize_datadir() {
  mkdir -p "$confdir"
  if [[ -f "${datadir}/PG_VERSION" ]]; then
    return 0
  fi
  if [[ ! -x "$initdb" ]]; then
    echo "initdb not found at ${initdb}" >&2
    return 1
  fi
  # builtin locale does not need a matching OS locale, so macOS and Linux match.
  "$initdb" \
    --pgdata="$datadir" \
    --username="$os_user" \
    --locale-provider=builtin \
    --locale=C.UTF-8 \
    --encoding=UTF8 \
    --auth-local=trust \
    --auth-host=trust \
    --no-instructions
}

ensure_superuser() {
  local name="$1"
  local lit ident
  lit="$(sql_literal "$name")"
  ident="$(sql_ident "$name")"
  "$psql" -h "$socket_dir" -d postgres -v ON_ERROR_STOP=1 <<SQL
DO \$\$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = '${lit}') THEN
    CREATE ROLE "${ident}" LOGIN SUPERUSER CREATEDB CREATEROLE REPLICATION BYPASSRLS PASSWORD NULL;
  ELSE
    ALTER ROLE "${ident}" WITH LOGIN SUPERUSER CREATEDB CREATEROLE REPLICATION BYPASSRLS PASSWORD NULL;
  END IF;
END
\$\$;
SQL
}

ensure_database() {
  local name="$1"
  local lit ident
  lit="$(sql_literal "$name")"
  ident="$(sql_ident "$name")"
  if "$psql" -h "$socket_dir" -d postgres -tAc "SELECT 1 FROM pg_database WHERE datname = '${lit}'" | grep -q 1; then
    return 0
  fi
  "$psql" -h "$socket_dir" -d postgres -v ON_ERROR_STOP=1 \
    -c "CREATE DATABASE \"${ident}\" OWNER \"${ident}\";"
}

provision_local_roles() {
  local started_tmp=0 tmp_log pid

  if [[ -z "$os_user" || "$os_user" == *$'\n'* ]]; then
    echo "refusing to provision Postgres role from empty/invalid OS username" >&2
    return 1
  fi

  if ! postgres_already_up; then
    tmp_log="$(mktemp)"
    started_tmp=1
    "$postgres" \
      -D "$datadir" \
      -c listen_addresses=localhost \
      -c unix_socket_directories="$socket_dir" \
      -c hba_file="$hba" \
      >"$tmp_log" 2>&1 &
    pid=$!

    cleanup_tmp() {
      if [[ "$started_tmp" -eq 1 ]] && kill -0 "$pid" 2>/dev/null; then
        "$pg_ctl" -D "$datadir" -m fast stop &>/dev/null || kill "$pid" 2>/dev/null || true
        wait "$pid" 2>/dev/null || true
      fi
      [[ -n "${tmp_log:-}" ]] && rm -f "$tmp_log"
    }
    trap cleanup_tmp EXIT
    if ! wait_for_postgres; then
      echo "---- postgres log ----" >&2
      cat "$tmp_log" >&2 || true
      return 1
    fi
  fi

  # `postgres` is the usual superuser name. When the OS user is also postgres,
  # initdb already created that role and database; ALTER is a no-op for auth.
  ensure_superuser postgres
  ensure_database postgres
  if [[ "$os_user" != postgres ]]; then
    ensure_superuser "$os_user"
    ensure_database "$os_user"
  fi

  if [[ "$started_tmp" -eq 1 ]]; then
    "$pg_ctl" -D "$datadir" -m fast stop
    wait "$pid" 2>/dev/null || true
    trap - EXIT
    rm -f "$tmp_log"
  elif postgres_already_up; then
    "$pg_ctl" -D "$datadir" reload
  fi
}

initdb="$(find_bin initdb)"
postgres="$(find_bin postgres)"
psql="$(find_bin psql)"
pg_ctl="$(find_bin pg_ctl)"
pg_isready="$(find_bin pg_isready)"

write_hba
initialize_datadir
provision_local_roles

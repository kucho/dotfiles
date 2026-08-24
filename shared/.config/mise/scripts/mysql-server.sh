#!/usr/bin/env bash
# Start the mise-managed MySQL 8 server in the foreground for launchd/systemd.
# Datadir init + OS user provisioning happen in mysql-postinstall.sh.
set -euo pipefail

basedir="${MYSQL_BASEDIR:-$HOME/.local/share/mise/installs/mysql/8}"
datadir="${MYSQL_DATADIR:-$HOME/.local/share/mysql/data}"
mysqld="${basedir}/bin/mysqld"
socket="${MYSQL_UNIX_PORT:-/tmp/mysql.sock}"

if [[ ! -x "$mysqld" ]]; then
  echo "mysqld not found at ${mysqld}; install with: mise install mysql@8" >&2
  exit 1
fi

if [[ ! -d "${datadir}/mysql" ]]; then
  echo "MySQL datadir is not initialized at ${datadir}." >&2
  echo "Reinstall the tool to run postinstall: mise install mysql@8 --force" >&2
  exit 1
fi

exec "$mysqld" \
  --basedir="$basedir" \
  --datadir="$datadir" \
  --bind-address=127.0.0.1 \
  --socket="$socket"

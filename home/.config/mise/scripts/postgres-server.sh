#!/usr/bin/env bash
# Start the mise-managed Postgres 18 server in the foreground for launchd/systemd.
# Datadir init + OS user provisioning happen in postgres-postinstall.sh.
set -euo pipefail

basedir="${POSTGRES_BASEDIR:-$HOME/.local/share/mise/installs/postgres/18}"
datadir="${PGDATA:-$HOME/.local/share/postgres/data}"
hba="${POSTGRES_HBA:-$(dirname "$datadir")/pg_hba.conf}"
socket_dir="${POSTGRES_SOCKET_DIR:-/tmp}"
postgres="${basedir}/bin/postgres"

if [[ ! -x "$postgres" && -x "${basedir}/pgsql/bin/postgres" ]]; then
  postgres="${basedir}/pgsql/bin/postgres"
  basedir="${basedir}/pgsql"
fi

if [[ ! -x "$postgres" ]]; then
  echo "postgres not found at ${postgres}; install with: mise install postgres@18" >&2
  exit 1
fi

if [[ ! -f "${datadir}/PG_VERSION" ]]; then
  echo "Postgres datadir is not initialized at ${datadir}." >&2
  echo "Reinstall the tool to run postinstall: mise install postgres@18 --force" >&2
  exit 1
fi

if [[ ! -f "$hba" ]]; then
  echo "Postgres hba file is missing at ${hba}." >&2
  echo "Reinstall the tool to run postinstall: mise install postgres@18 --force" >&2
  exit 1
fi

# Conda prefixes need their own lib dir when started outside mise activation.
export LD_LIBRARY_PATH="${basedir}/lib${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
if [[ "$(uname -s)" == Darwin ]]; then
  export DYLD_LIBRARY_PATH="${basedir}/lib${DYLD_LIBRARY_PATH:+:$DYLD_LIBRARY_PATH}"
fi

# Local-dev counterparts of the MySQL server flags:
# listen on loopback only, socket in /tmp, no replication WAL (skip-log-bin),
# and a large cache (innodb-buffer-pool-size=4G).
exec "$postgres" \
  -D "$datadir" \
  -c listen_addresses=localhost \
  -c unix_socket_directories="$socket_dir" \
  -c hba_file="$hba" \
  -c shared_buffers=4GB \
  -c wal_level=minimal \
  -c max_wal_senders=0 \
  -c max_replication_slots=0

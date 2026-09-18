#!/bin/sh
# User ssh-agent for headless Linux: listen on $XDG_RUNTIME_DIR/ssh-agent.socket
# and load ~/.ssh/id_ed25519 when that file exists.
set -eu

runtime="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"
sock="$runtime/ssh-agent.socket"
key="${HOME}/.ssh/id_ed25519"

rm -f "$sock"
/usr/bin/ssh-agent -D -a "$sock" &
agent_pid=$!

i=0
while [ ! -S "$sock" ]; do
  i=$((i + 1))
  if [ "$i" -gt 50 ]; then
    echo "ssh-agent-with-key: socket never appeared at $sock" >&2
    kill "$agent_pid" 2>/dev/null || true
    exit 1
  fi
  sleep 0.1
done

if [ -f "$key" ]; then
  SSH_AUTH_SOCK="$sock" /usr/bin/ssh-add "$key"
else
  echo "ssh-agent-with-key: no $key (agent is empty)" >&2
fi

wait "$agent_pid"

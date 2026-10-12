#!/usr/bin/env bash
# aqua publishes only the agent-browser binary. `skills get` looks for a
# skills/ directory beside that binary (or a parent it walks up to), then
# reads skills/ and skill-data/ from that root. Fetch the matching tag so the
# served skill stays version-matched without an npm install.
set -euo pipefail

version="${MISE_TOOL_VERSION:?MISE_TOOL_VERSION is unset}"
version="${version#v}"
root="${MISE_TOOL_INSTALL_PATH:?MISE_TOOL_INSTALL_PATH is unset}"

if [[ -L "$root" ]]; then
  root="$(cd "$root" && pwd -P)"
fi

workdir="$(mktemp -d)"
trap 'rm -rf "$workdir"' EXIT

curl -fsSL -o "$workdir/src.tar.gz" \
  "https://github.com/vercel-labs/agent-browser/archive/refs/tags/v${version}.tar.gz"
tar -xzf "$workdir/src.tar.gz" -C "$workdir"

src="$workdir/agent-browser-${version}"
if [[ ! -d "$src/skills" || ! -d "$src/skill-data" ]]; then
  echo "agent-browser ${version} archive is missing skills/ or skill-data/" >&2
  exit 1
fi

rm -rf "$root/skills" "$root/skill-data"
cp -R "$src/skills" "$src/skill-data" "$root/"

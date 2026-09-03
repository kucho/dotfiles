#!/usr/bin/env bash
# mise http backend postinstall for AWS session-manager-plugin.
# macOS ships a zip (auto-extracted). Linux ships a .deb that mise cannot unpack.
set -euo pipefail

root="${MISE_TOOL_INSTALL_PATH:?}"
if [[ -L "$root" ]]; then
  root="$(readlink -f "$root")"
fi

has_binary() {
  local candidate="$1"
  [[ -f "$candidate" && -x "$candidate" ]] || return 1
  file -b "$candidate" | grep -Eq 'ELF|Mach-O'
}

if has_binary "$root/bin/session-manager-plugin"; then
  exit 0
fi

# Official macOS bundle layout
if has_binary "$root/sessionmanager-bundle/bin/session-manager-plugin"; then
  mkdir -p "$root/bin"
  ln -sfn ../sessionmanager-bundle/bin/session-manager-plugin "$root/bin/session-manager-plugin"
  exit 0
fi

# Official Linux package is a .deb left as a raw http artifact
deb=""
while IFS= read -r -d '' f; do
  real="$(readlink -f "$f")"
  [[ -f "$real" ]] || continue
  if file -b "$real" | grep -qiE 'debian|ar archive'; then
    deb="$real"
    break
  fi
done < <(find -H "$root" \( -type f -o -type l \) -print0 2>/dev/null)

# Nothing to fix (e.g. unexpected layout)
[[ -n "$deb" ]] || exit 0

work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT
cp "$deb" "$work/plugin.deb"
pushd "$work" >/dev/null
ar x plugin.deb
tar xf data.tar.*
popd >/dev/null

mkdir -p "$root/bin"
cp "$work/usr/local/sessionmanagerplugin/bin/session-manager-plugin" \
  "$root/bin/session-manager-plugin"
chmod +x "$root/bin/session-manager-plugin"

# Remove raw .deb artifacts so shims resolve the real binary
find "$root" -maxdepth 2 \( -type f -o -type l \) -name '*.deb' -delete 2>/dev/null || true

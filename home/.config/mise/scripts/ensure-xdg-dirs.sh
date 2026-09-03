#!/usr/bin/env bash
set -euo pipefail

mkdir -p "$HOME/.config" "$HOME/.cache" "$HOME/.local/share" \
  "$HOME/.local/state" "$HOME/.local/run" "$HOME/.local/bin"
chmod 700 "$HOME/.local/run"

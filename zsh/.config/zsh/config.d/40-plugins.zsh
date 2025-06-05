#!/bin/zsh

if (( ! ${+commands[mise]} )); then
  curl https://mise.jdx.dev/install.sh | sh
fi

eval "$(mise activate zsh)"

if (( ! ${+commands[cargo]} )); then
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --profile default
fi

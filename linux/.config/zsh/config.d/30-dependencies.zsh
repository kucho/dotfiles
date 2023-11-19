#!/bin/zsh

# Use 1Password auth sock
export SSH_AUTH_SOCK=~/.1password/agent.sock

if (( ! ${+commands[rtx]} )); then
  curl https://rtx.pub/rtx-latest-linux-x64 > ~/.local/bin/rtx
  chmod +x ~/.local/bin/rtx
fi

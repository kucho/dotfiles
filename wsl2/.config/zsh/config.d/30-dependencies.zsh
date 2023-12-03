#!/bin/zsh

if (( ! ${+commands[rtx]} )); then
  curl https://rtx.pub/rtx-latest-linux-x64 > ~/.local/bin/rtx
  chmod +x ~/.local/bin/rtx
fi

alias ssh='ssh.exe'
alias ssh-add='ssh-add.exe'

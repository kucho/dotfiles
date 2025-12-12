#!/bin/zsh

##
# Environment variables
#

export BUN_INSTALL="$HOME/.bun"

[ ! -d ~/.local/bin ] && mkdir -p ~/.local/bin

path=(
  $path
  ~/.local/bin
  $BUN_INSTALL/bin
)

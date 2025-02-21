#!/bin/zsh

##
# Environment variables
#

export MISE_ENV_FILE=.env
export BUN_INSTALL="$HOME/.bun"

[ ! -d ~/.local/bin ] && mkdir -p ~/.local/bin

path=(
  $path
  ~/.local/bin
  $BUN_INSTALL/bin
)

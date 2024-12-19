#!/bin/zsh

##
# Environment variables
#

export MISE_ENV_FILE=.env

# Ruby opts
export RUBY_CONFIGURE_OPTS=--enable-yjit
export RUBY_YJIT_ENABLE=1

export BUN_INSTALL="$HOME/.bun"

[ ! -d ~/.local/bin ] && mkdir -p ~/.local/bin

path=(
  $path
  ~/.local/bin
  $BUN_INSTALL/bin
)

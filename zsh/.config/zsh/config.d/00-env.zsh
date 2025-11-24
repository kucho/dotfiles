#!/bin/zsh

##
# Environment variables
#

[ ! -d ~/.local/bin ] && mkdir -p ~/.local/bin

path=(
  $path
  ~/.local/bin
)

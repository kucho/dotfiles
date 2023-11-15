#!/bin/zsh

##
# Environment variables
#

# -U ensures each entry in these is unique (that is, discards duplicates).
export -U PATH path FPATH fpath MANPATH manpath
export -UT INFOPATH infopath # -T creates a "tied" pair; see below.

# Ruby opts
export RUBY_CONFIGURE_OPTS=--enable-yjit
export RUBY_YJIT_ENABLE=1

# $PATH and $path (and also $FPATH and $fpath, etc.) are "tied" to each other.
# Modifying one will also modify the other.
# Note that each value in an array is expanded separately. Thus, we can use ~
# for $HOME in each $path entry.
path=(
  $path
  ~/.local/bin
)

# Add your functions to your $fpath, so you can autoload them.
fpath=(
  $ZDOTDIR/functions
  $fpath
  ~/.local/share/zsh/site-functions
)

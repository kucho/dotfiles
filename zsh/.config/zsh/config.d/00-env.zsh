#!/bin/zsh

##
# Environment variables
#

# Issue https://github.com/zimfw/zimfw/issues/504
export LANGUAGE=en_US.UTF-8
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
export LC_CTYPE=en_US.UTF-8

export ZSH_CACHE_DIR=${XDG_CACHE_HOME:-$HOME/.cache}/zsh
mkdir -p $ZSH_CACHE_DIR/{history,fc-cache,completions}

# Highlight matches in autosuggestions
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=137'

# -U ensures each entry in these is unique (that is, discards duplicates).
export -U PATH path FPATH fpath MANPATH manpath
export -UT INFOPATH infopath # -T creates a "tied" pair; see below.

# Ruby opts
export RUBY_CONFIGURE_OPTS=--enable-yjit
export RUBY_YJIT_ENABLE=1

export BUN_INSTALL="$HOME/.bun"

# $PATH and $path (and also $FPATH and $fpath, etc.) are "tied" to each other.
# Modifying one will also modify the other.
# Note that each value in an array is expanded separately. Thus, we can use ~
# for $HOME in each $path entry.

mkdir -p ~/.local/bin

path=(
  $path
  ~/.local/bin
  $BUN_INSTALL/bin
)

# Add your functions to your $fpath, so you can autoload them.
fpath=(
  $ZDOTDIR/functions
  $fpath
  ~/.local/share/zsh/site-functions
)

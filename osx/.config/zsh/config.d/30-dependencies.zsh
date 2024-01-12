#!/bin/zsh

##
# OS specific dependencies
#

# Use 1Password auth sock
export SSH_AUTH_SOCK=~/Library/Group\ Containers/2BUA8C4S2C.com.1password/t/agent.sock

# Issue: https://github.com/rails/rails/issues/38560
export OBJC_DISABLE_INITIALIZE_FORK_SAFETY=YES

# Insall brew and dependencies
if (( ! ${+commands[brew]} )); then
  /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" &>/dev/null
  cd ~ && brew bundle &>/dev/nul
fi

fpath+=($(brew --prefix)/share/zsh/site-functions)

# Add libpq to path
path+=($(brew --prefix libpq)/bin)

if (( ! ${+commands[mise]} )); then
  curl https://mise.jdx.dev/install.sh | sh
fi

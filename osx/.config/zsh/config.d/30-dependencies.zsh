#!/bin/zsh

##
# OS specific dependencies
#

# Insall brew and dependencies
if (( ! ${+commands[brew]} )); then
  /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" &>/dev/null
  cd ~ && brew bundle &>/dev/nul
fi

fpath+=($(brew --prefix)/share/zsh/site-functions)

# Add libpq to path
path+=($(brew --prefix libpq)/bin)

# Use 1Password auth sock
export SSH_AUTH_SOCK=~/Library/Group\ Containers/2BUA8C4S2C.com.1password/t/agent.sock

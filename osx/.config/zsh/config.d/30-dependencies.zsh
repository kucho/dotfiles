#!/bin/zsh

##
# OS specific dependencies
#

# Use 1Password auth sock
export SSH_AUTH_SOCK=~/Library/Group\ Containers/2BUA8C4S2C.com.1password/t/agent.sock

fpath=(/opt/homebrew/share/zsh/site-functions(N) ${fpath})

# Add libpq to path
path+=(/opt/homebrew/opt/libpq/bin)

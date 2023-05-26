#!/bin/zsh

##
# OS specific dependencies
#

# Insall brew and dependencies
function install_homebrew {
  if [[ $(command -v brew) == "" ]]; then
    /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" &>/dev/null
  else
    brew update &>/dev/null
  fi

  cd ~ && brew bundle &>/dev/nul
}

znap eval _homebrew install_homebrew

# Add libpq to path
path+=($(brew --prefix libpq)/bin)

# Enable asdf
. $(brew --prefix asdf)/libexec/asdf.sh

# Hook zsh to shell
znap eval direnv 'direnv hook zsh'

znap eval iterm2 'curl -fsSL https://iterm2.com/shell_integration/zsh'

# Use 1Password auth sock
export SSH_AUTH_SOCK=~/Library/Group\ Containers/2BUA8C4S2C.com.1password/t/agent.sock

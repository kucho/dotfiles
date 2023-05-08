function install_homebrew {
  if [[ $(command -v brew) == "" ]]; then
    /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" &>/dev/null
  else
    brew update &>/dev/null
  fi
}

znap eval _homebrew install_homebrew
znap eval _install_dependencies 'cd ~ && brew bundle &>/dev/null'

#!/bin/zsh

ZIM_HOME=~/Git/zim
# Download zimfw plugin manager if missing.
if [[ ! -e ${ZIM_HOME}/zimfw.zsh ]]; then
  curl -fsSL --create-dirs -o ${ZIM_HOME}/zimfw.zsh \
      https://github.com/zimfw/zimfw/releases/latest/download/zimfw.zsh
fi

# Install missing modules, and update ${ZIM_HOME}/init.zsh if missing or outdated.
if [[ ! ${ZIM_HOME}/init.zsh -nt ${ZDOTDIR:-${HOME}}/.zimrc ]]; then
  source ${ZIM_HOME}/zimfw.zsh init -q
fi

source ${ZIM_HOME}/init.zsh

if (( ${+commands[mise]} )); then
  eval "$(mise activate zsh)"
  eval "$(mise hook-env)"
fi

if (( ${+commands[direnv]} )); then
  eval "$(direnv hook zsh)"
fi

# Download fzf, if it's not here yet.
if [ ! -f ~/Git/fzf/install ]; then
	git clone --depth 1 https://github.com/junegunn/fzf.git ~/Git/fzf
	printf 'y\ny\ny\n' | ~/Git/fzf/install
fi

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

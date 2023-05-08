# Plugins
znap eval starship 'starship init zsh --print-full-init'
znap prompt

ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets)
znap source zsh-users/zsh-syntax-highlighting

znap source marlonrichert/zsh-autocomplete

ZSH_AUTOSUGGEST_STRATEGY=(history)
znap source zsh-users/zsh-autosuggestions

znap source MichaelAquilina/zsh-you-should-use

. $(brew --prefix asdf)/libexec/asdf.sh
znap eval direnv 'direnv hook zsh'
znap eval zsh-completions "znap install zsh-users/zsh-completions"
znap eval iterm2 'curl -fsSL https://iterm2.com/shell_integration/zsh'

znap fpath _kubectl 'kubectl completion zsh'

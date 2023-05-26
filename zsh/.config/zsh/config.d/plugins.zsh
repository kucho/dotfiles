ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets)
znap source zsh-users/zsh-syntax-highlighting

znap source marlonrichert/zsh-autocomplete

ZSH_AUTOSUGGEST_STRATEGY=(history)
znap source zsh-users/zsh-autosuggestions

znap source MichaelAquilina/zsh-you-should-use
znap source wintermi/zsh-gcloud

znap eval zsh-completions "znap install zsh-users/zsh-completions"
znap fpath _kubectl 'kubectl completion zsh'

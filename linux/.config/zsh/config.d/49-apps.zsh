znap source asdf-vm/asdf asdf.sh
znap eval _install_direnv "asdf plugin-add direnv && asdf install direnv latest && asdf global direnv latest &>/dev/null"
znap eval asdf-community/asdf-direnv "asdf exec $(asdf which direnv) hook zsh"

fpath+=( ~[asdf-community/asdf-direnv]/completions )

# Use 1Password auth sock
export SSH_AUTH_SOCK=~/.1password/agent.sock

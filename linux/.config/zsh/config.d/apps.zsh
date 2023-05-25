znap source asdf-vm/asdf
znap eval asdf-community/asdf-direnv "asdf exec $(asdf which direnv) hook zsh" # cache the result


# Path
fpath+=(
    ~[asdf-vm/asdf]/completions
    ~[asdf-community/asdf-direnv]/completions
    ~[zsh-users/zsh-completions]/src
)

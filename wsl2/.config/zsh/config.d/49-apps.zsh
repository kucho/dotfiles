#!/bin/zsh

znap source asdf-vm/asdf asdf.sh

if ! command_exists direnv; then
  asdf plugin-add direnv && asdf install direnv latest && asdf global direnv latest &>/dev/null
fi

if ! command_exists socat; then
  sudo apt install socat
fi

znap eval asdf-community/asdf-direnv "asdf exec $(asdf which direnv) hook zsh"

fpath+=( ~[asdf-community/asdf-direnv]/completions )

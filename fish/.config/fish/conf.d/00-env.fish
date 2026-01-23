# Environment variables

set -gx BUN_INSTALL $HOME/.bun

test -d ~/.local/bin; or mkdir -p ~/.local/bin

fish_add_path -aP ~/.local/bin
fish_add_path -aP ~/.cargo/bin
fish_add_path -aP $BUN_INSTALL/bin

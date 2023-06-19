# Check packages dir
DIR="$HOME/Git"
if [ ! -d "$DIR" ]; then
	echo "Creating packages folder ${DIR}..."
	mkdir "$DIR"
fi

# Download Znap, if it's not there yet.
[[ -f ~/Git/zsh-snap/znap.zsh ]] ||
	git clone --depth 1 -- https://github.com/marlonrichert/zsh-snap.git ~/Git/zsh-snap

source ~/Git/zsh-snap/znap.zsh # Start Znap

# Download fzf, if it's not here yet.
if [ ! -f ~/Git/fzf/install ]; then
	git clone --depth 1 https://github.com/junegunn/fzf.git ~/Git/fzf
	printf 'y\ny\ny\n' | ~/Git/fzf/install
fi

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# Download starship, if it's not there yet.
if [ ! -f /usr/local/bin/starship ]; then
	curl -sS https://starship.rs/install.sh | sh
fi

function command_exists() {
	type "$1" &>/dev/null
}

# Load config files
for conf in "$HOME/.config/zsh/config.d/"*.zsh; do
	source "${conf}"
done
unset conf

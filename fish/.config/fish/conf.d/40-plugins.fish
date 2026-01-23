# Plugin/tool activation

if not command -q mise
    curl https://mise.jdx.dev/install.sh | sh
end

if status is-interactive
    mise activate fish | source
else
    mise activate fish --shims | source
end

if not command -q cargo
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --profile default
end

if not command -q starship
    curl -sS https://starship.rs/install.sh | sh -s -- -y
    starship preset pure-preset -o ~/.config/starship.toml
end

starship init fish | source

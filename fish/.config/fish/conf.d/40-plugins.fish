# Plugin/tool activation

if not command -q mise
    curl https://mise.jdx.dev/install.sh | sh
end

if status is-interactive
    mise activate fish | source
else
    mise activate fish --shims | source
end

fnox activate fish | source

if not type -q fisher
  curl -sL https://git.io/fisher | source
  fisher install jorgebucaran/fisher
end

if not set -q _fisher_plugins[1]
  fisher update
end

starship init fish | source

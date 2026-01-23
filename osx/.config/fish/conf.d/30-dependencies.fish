# OS specific dependencies (macOS)

# Initialize Homebrew
/opt/homebrew/bin/brew shellenv | source

# Use 1Password auth sock
set -gx SSH_AUTH_SOCK ~/Library/Group\ Containers/2BUA8C4S2C.com.1password/t/agent.sock

# Add libpq to path
fish_add_path -aP /opt/homebrew/opt/libpq/bin

# Homebrew settings
set -gx HOMEBREW_NO_ANALYTICS 1
set -gx HOMEBREW_NO_ENV_HINTS 1

# OS specific dependencies (Linux)

# Use 1Password SSH agent locally, but respect forwarded agent over SSH
if not set -q SSH_CONNECTION
    set -gx SSH_AUTH_SOCK ~/.1password/agent.sock
end

if not command -q zed; and command -q zeditor
    alias zed zeditor
end

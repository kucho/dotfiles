use std/util "path add"

$env.MISE_ENV_FILE = ".env"
$env.BUN_INSTALL = $nu.home-path | path join .bun
$env.SSH_AUTH_SOCK =  $nu.home-path | path join Library/Group\ Containers/2BUA8C4S2C.com.1password/t/agent.sock

path add "/opt/homebrew/bin"
path add -a "~/.local/bin"
path add -a ($env.BUN_INSTALL | path join bin)
path add -a "/opt/homebrew/opt/libpq/bin"

let mise_path = $nu.default-config-dir | path join mise.nu
^mise activate nu | save $mise_path --force

zoxide init --cmd cd nushell | save -f ($nu.default-config-dir | path join zoxide.nu)

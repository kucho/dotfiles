use std/util "path add"

$env.MISE_ENV_FILE = ".env"
$env.BUN_INSTALL = $nu.home-path | path join .bun

path add "/opt/homebrew/bin"
path add -a "~/.local/bin"
path add -a ($env.BUN_INSTALL | path join bin)

let mise_path = $nu.default-config-dir | path join mise.nu
^mise activate nu | save $mise_path --force

zoxide init --cmd cd nushell | save -f ($nu.default-config-dir | path join zoxide.nu)

$env.MISE_ENV_FILE = ".env"
$env.BUN_INSTALL = $nu.home-path | path join .bun

use std/util "path add"
path add -a ($nu.home-path | path join .cargo/bin)
path add -a ($nu.home-path | path join .local/bin)
path add -a ($env.BUN_INSTALL | path join bin)
path add -a "/usr/local/bin"

const os_path = $nu.default-config-dir | path join modules/os.nu
const os_module = if ($os_path | path exists) { $os_path } else { null }
source $os_module

$env.LS_COLORS = (vivid generate molokai)

const autoload_path = $nu.data-dir | path join vendor/autoload
mkdir $autoload_path

^mise activate nu | save ($autoload_path | path join mise.nu) --force

zoxide init --cmd cd nushell | save -f ($autoload_path | path join zoxide.nu)

starship init nu | save -f ($autoload_path | path join starship.nu)

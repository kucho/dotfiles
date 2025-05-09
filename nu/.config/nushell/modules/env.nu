$env.MISE_ENV_FILE = ".env"
$env.BUN_INSTALL = $nu.home-path | path join .bun

use std/util "path add"
path add -a ($nu.home-path | path join .cargo/bin)
path add -a ($nu.home-path | path join .local/bin)
path add -a ($env.BUN_INSTALL | path join bin)

const os_path = $nu.default-config-dir | path join modules/os.nu
const os_module = if ($os_path | path exists) { $os_path } else { null }
source $os_module

$env.LS_COLORS = (vivid generate modus-operandi)

const mise_path = $nu.default-config-dir | path join mise.nu
^mise activate nu | save $mise_path --force
use $mise_path

zoxide init --cmd cd nushell | save -f ($nu.default-config-dir | path join zoxide.nu)
source ($nu.default-config-dir | path join zoxide.nu)

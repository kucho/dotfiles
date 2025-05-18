source modules/env.nu
source modules/completion.nu
source modules/aliases.nu

$env.config = {
  highlight_resolved_externals: true
  show_banner: true
  use_kitty_protocol: true
  color_config: {
    separator: dark_gray
  }
}

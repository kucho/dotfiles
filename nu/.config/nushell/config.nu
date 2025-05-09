source modules/env.nu
source modules/completion.nu

$env.config = {
  highlight_resolved_externals: true
  show_banner: false
  use_kitty_protocol: true
  color_config: {
    separator: dark_gray
    string: black
  }
}

$env.PROMPT_COMMAND_RIGHT = {|| }

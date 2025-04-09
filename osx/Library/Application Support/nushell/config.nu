use ($nu.default-config-dir | path join mise.nu)
source ($nu.default-config-dir | path join zoxide.nu)

$env.config = {
    highlight_resolved_externals: true
    show_banner: false
    use_kitty_protocol: true
}

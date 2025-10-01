# Documentation: https://github.com/romkatv/zsh4humans/blob/v5/README.md.

zstyle ':z4h:'                   auto-update               true
zstyle ':z4h:'                   auto-update-days          28
zstyle ':z4h:bindkey'            keyboard                  mac
zstyle ':z4h:'                   start-tmux                no
zstyle ':z4h:'                   term-shell-integration    yes
zstyle ':z4h:autosuggestions'    forward-char              accept
zstyle ':z4h:fzf-complete'       recurse-dirs              yes
zstyle ':z4h:direnv'             enable                    no
zstyle ':z4h:direnv:success'     notify                    no
zstyle ':z4h:ssh:*'              enable                    yes
zstyle ':z4h:ssh:*'              send-extra-files          '~/.config/zsh/config.d'

z4h init || return

autoload -Uz zmv

for conf in $HOME/.config/zsh/config.d/*.zsh; do
  z4h source -c -- ${conf}
done
unset conf

z4h compile -- $ZDOTDIR/{.zshenv,.zprofile,.zshrc,.zlogin,.zlogout}

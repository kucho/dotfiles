# Commands, functions and aliases

# Pager default
set -gx PAGER less

# Aliases
alias lg lazygit
alias dev bin/dev
alias until_failure ~/scripts/until_failure
alias tree 'tree -a -I .git'
alias ls 'eza --group-directories-first --icons -A'

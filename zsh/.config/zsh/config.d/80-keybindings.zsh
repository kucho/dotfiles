z4h bindkey undo Ctrl+/    Shift+Tab    # undo the last command line change
z4h bindkey redo Option+/               # redo the last undone command line change

z4h bindkey z4h-cd-back    Shift+Left   # cd into the previous directory
z4h bindkey z4h-cd-forward Shift+Right  # cd into the next directory
z4h bindkey z4h-cd-up      Shift+Up     # cd into the parent directory
z4h bindkey z4h-cd-down    Shift+Down   # cd into a child directory

zstyle ':z4h:fzf-complete'    fzf-bindings tab:repeat
zstyle ':z4h:fzf-dir-history' fzf-bindings tab:repeat
zstyle ':z4h:cd-down'         fzf-bindings tab:repeat

z4h bindkey z4h-fzf-dir-history Alt+Down

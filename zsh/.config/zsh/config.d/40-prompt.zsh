#!/bin/zsh

##
# Prompt theme
#

# Reduce startup time by making the left side of the primary prompt visible
# *immediately.*
znap eval starship 'starship init zsh --print-full-init'
znap prompt

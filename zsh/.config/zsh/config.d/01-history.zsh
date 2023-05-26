#!/bin/zsh

##
# History settings
#
# Always set these first, so history is preserved, no matter what happens.
#

# Enable additional glob operators. (Globbing = pattern matching)
# https://zsh.sourceforge.io/Doc/Release/Expansion.html#Filename-Generation
setopt EXTENDED_GLOB

# Tell zsh where to store history.
HISTFILE=${XDG_DATA_HOME:=~/.local/share}/zsh/history

# Just in case: If the parent directory doesn't exist, create it.
[[ -d $HISTFILE:h ]] ||
  mkdir -p $HISTFILE:h

# Max number of entries to keep in history file.
SAVEHIST=$((100 * 1000)) # Use multiplication for readability.

# Max number of history entries to keep in memory.
HISTSIZE=$((1.2 * SAVEHIST)) # Zsh recommended value

# Use modern file-locking mechanisms, for better safety & performance.
setopt HIST_FCNTL_LOCK

# Keep only the most recent copy of each duplicate entry in history.
setopt HIST_IGNORE_ALL_DUPS

# Do Not Record An Event That Was Just Recorded Again.
setopt HIST_IGNORE_DUPS

# Do Not Write A Duplicate Event To The History File.
setopt HIST_SAVE_NO_DUPS

# Expire A Duplicate Event First When Trimming History.
setopt HIST_EXPIRE_DUPS_FIRST

# Write To The History File Immediately, Not When The Shell Exits.
setopt INC_APPEND_HISTORY

# Share History Between All Sessions.
setopt SHARE_HISTORY

# Do Not Display A Previously Found Event.
setopt HIST_FIND_NO_DUPS

# Do Not Record An Event Starting With A Space.
setopt HIST_IGNORE_SPACE

# Do Not Execute Immediately Upon History Expansion.
setopt HIST_VERIFY

# Show Timestamp In History.
setopt EXTENDED_HISTORY

##
# Plugins
#

# Add the plugins you want to use here.
# For more info on each plugin, visit its repo at github.com/<plugin>
# -a sets the variable's type to array.
local -a plugins=(
  marlonrichert/zsh-autocomplete    # Real-time type-ahead completion
  zsh-users/zsh-autosuggestions     # Inline suggestions
  zsh-users/zsh-syntax-highlighting # Command-line syntax highlighting
  marlonrichert/zsh-edit            # Better keyboard shortcuts
  marlonrichert/zsh-hist            # Edit history from the command line
  MichaelAquilina/zsh-you-should-use
)

# The Zsh Autocomplete plugin sends *a lot* of characters to your terminal.
# This is fine locally on modern machines, but if you're working through a slow
# ssh connection, you might want to add a slight delay before the
# autocompletion kicks in:
zstyle ':autocomplete:*' min-delay 0.5 # seconds

# If your connection is VERY slow, then you might want to disable
# autocompletion completely and use only tab completion instead:
#   zstyle ':autocomplete:*' async no

# Speed up the first startup by cloning all plugins in parallel.
# This won't clone plugins that we already have.
znap clone $plugins

# Load each plugin, one at a time.
local p=
for p in $plugins; do
  znap source $p
done

# Add ohmyzsh functions and autocompletions
znap source ohmyzsh/ohmyzsh lib/completion \
  plugins/{git,command-not-found,kubectl,gcloud,asdf}

znap eval zsh-completions "znap install zsh-users/zsh-completions"

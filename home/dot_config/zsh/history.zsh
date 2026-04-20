# HISTFILE="$HOME/.config/zsh/history"

# Maximum events in memory (default: 30)
HISTSIZE=1000000

# Maximum events saved to file (default: 0)
SAVEHIST=1000000

# Ignore commands starting with a space
setopt HIST_IGNORE_SPACE

# Remove older duplicate when a new entry is added
setopt HIST_IGNORE_ALL_DUPS

# Expire duplicates first when trimming history
setopt HIST_EXPIRE_DUPS_FIRST

# Strip superfluous blanks (trailing, internal) from history entries
setopt HIST_REDUCE_BLANKS

# Expand history substitution before executing
setopt HIST_VERIFY

# Append history on shell exit instead of overwriting
setopt APPEND_HISTORY

# Share history between concurrent sessions
setopt SHARE_HISTORY

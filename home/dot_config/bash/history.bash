# Ignore space-prefixed, duplicates, and erase older dupes
HISTCONTROL=ignorespace:ignoredups:erasedups

# HISTFILE="$HOME/.config/bash/history"

# Unlimited in-memory history (default: 500)
HISTSIZE=-1

# Unlimited history file; defaults to HISTSIZE when unset
# HISTFILESIZE=$HISTSIZE

# Timestamp format for history entries (default: unset)
# HISTTIMEFORMAT="%F %T "
HISTTIMEFORMAT='%Y-%m-%d:%H:%M '

# Append to history file instead of overwriting
shopt -s histappend

# Save multi-line commands as one history entry
shopt -s cmdhist

# Re-edit failed history substitutions
shopt -s histreedit

# Expand history substitution before executing
shopt -s histverify

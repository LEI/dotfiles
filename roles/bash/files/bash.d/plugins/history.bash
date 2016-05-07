#
# Bash history
#

# Append to the Bash history file, rather than overwriting it
shopt -s histappend

# Erase duplicates (or 'ignoredups')
export HISTCONTROL=${HISTCONTROL:-erasedups}

# History size
export HISTSIZE=${HISTSIZE:-5000}

#
# Bash history
#

# Erase duplicates (or 'ignoredups')
export HISTCONTROL=${HISTCONTROL:-erasedups}

# History size
export HISTSIZE=${HISTSIZE:-10000}
export HISTFILESIZE=${HISTFILESIZE:-10000}

# Append to the Bash history file, rather than overwriting it
shopt -s histappend

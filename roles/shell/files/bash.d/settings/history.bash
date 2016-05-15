# Bash history

# Erase duplicates (or 'ignoredups'?)
HISTCONTROL=${HISTCONTROL:-erasedups}

# History size
HISTSIZE=${HISTSIZE:-10000}
HISTFILESIZE=${HISTFILESIZE:-10000}

# History date time format
HISTTIMEFORMAT='%F %T '

# Append to the Bash history file, rather than overwriting it
shopt -s histappend

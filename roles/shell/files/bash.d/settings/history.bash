# Bash history

# Append to the Bash history file, rather than overwriting it
shopt -s histappend

# Erase duplicates (or 'ignoredups'?)
HISTCONTROL=${HISTCONTROL:-erasedups}

# History size
HISTSIZE=${HISTSIZE:-10000}
HISTFILESIZE=${HISTFILESIZE:-10000}

# History date time format
HISTTIMEFORMAT='%F %T '

# Disable shared history (~/.bash_sessions_disable)
SHELL_SESSION_HISTORY=0

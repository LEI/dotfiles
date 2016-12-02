# Bash history

# Double check all expansions before submitting a command
# shopt -s histverify histreedit

# Append to the Bash history file, rather than overwriting it
shopt -s histappend

# Erase duplicates
HISTCONTROL=${HISTCONTROL:-erasedups}
# HISTCONTROL=ignoredups:erasedups
# PROMPT_COMMAND="history -a;history -c;history -r;$PROMPT_COMMAND"

# History size
HISTSIZE=${HISTSIZE:-10000}
HISTFILESIZE=${HISTFILESIZE:-10000}

# History date time format
HISTTIMEFORMAT='%F %T '

# Disable shared history (~/.bash_sessions_disable)
SHELL_SESSION_HISTORY=0

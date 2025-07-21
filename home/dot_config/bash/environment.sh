HISTCONTROL=ignorespace:ignoredups:erasedups
# HISTFILE="$HOME/.config/bash/history"
HISTFILESIZE=-1
HISTSIZE=-1
# HISTTIMEFORMAT="%F %T "
HISTTIMEFORMAT='%Y-%m-%d:%H:%M '

# PROMPT_COMMAND="history -a; $PROMPT_COMMAND"
function _setAndReloadHistory {
  builtin history -a
  builtin history -c
  builtin history -r
}
PROMPT_COMMAND="${PROMPT_COMMAND:+$PROMPT_COMMAND; } _setAndReloadHistory"

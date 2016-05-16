# IRC

IRC="weechat"

alias weechat="irc"

irc() {
  if [[ -n "$TMUX" ]]; then
    TERM=screen-256color "$IRC" "$@"
  else
    "$IRC" "$@"
  fi
}

# IRC

IRC="iii"

irc() {
  args="h=50 n=irc.freenode.net" #c=
  if [[ -n "$TMUX" ]]
  then
    TERM=screen-256color "$args" "$IRC" "$@"
  else
    "$args" "$IRC" "$@"
  fi
}

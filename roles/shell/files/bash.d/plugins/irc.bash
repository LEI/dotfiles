# IRC

IRC="weechat"
# alias weechat="irc"

irc() {
  if [[ -n "$TMUX" ]]
  then
    TERM=screen-256color "$IRC" "$@"
  else
    "$IRC" "$@"
  fi
}

# irc() {
#   local IRC="~/irc/bin/iii"
#   local chan="${1:-}"
#   local serv="irc.freenode.net"
#   local hist=50
#   local args=("h=$hist" "n=$serv")
#   if [[ -n "$chan" ]]
#   then
#     args+=("c=$chan")
#     shift
#   fi
#   ${args[@]} "$IRC" "$@"
# }

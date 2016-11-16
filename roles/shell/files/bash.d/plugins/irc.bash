# IRC

ircbin="${ircbin:-$HOME/irc/bin}"

# Server info functions
freenode() {
  server="irc.freenode.net"
  channels="#foo" #bar
}

irc() {
  networks="${1:-freenode}"

  local connect="$ircbin/connect"
  local tmiii="$ircbin/tmiii"
  if [[ ! -e "$tmiii" ]] || [[ ! -e "$connect" ]]
  then
    if has weechat
    then
      IRC="weechat"
      [[ -n "$TMUX" ]] && TERM=screen-256color "$IRC" "$@" || "$IRC" "$@"
      return
    fi
    return 1
  fi

  # if [[ -z "$(ps -A | grep $connect)" ]]
  # then
    networks="$networks" "$connect"
  # fi

  local opts= hist=50
  for network in $networks
  do
    unset server channels
    "$network"
    for channel in $channels
    do
      opts="h=$hist n=$server c=$channel"
      env $opts "$tmiii"
    done
  done
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

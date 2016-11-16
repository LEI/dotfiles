# IRC

# if [[ ! -e "$connect" ]] || [[ ! -e "$tmiii" ]]
# then
#   if has weechat
#   then
#     IRC="weechat"
#     [[ -n "$TMUX" ]] && TERM=screen-256color "$IRC" "$@" || "$IRC" "$@"
#     return
#   fi
#   return 1
# fi

ircdir="$HOME/irc"
ircbin="${ircbin:-$ircdir/bin}"

irc() {
  local connect="$ircbin/connect"
  local tmiii="$ircbin/tmiii"

  local server="${1:-}"
  if [[ -n "$server" ]]
  then
    networks=("$server")
    shift
    channels=("$@")
  else
    [[ -f "$ircdir/autojoin" ]] && source "$ircdir/autojoin" || {
      echo "Not found: $ircdir/autojoin"
    }
  fi

  if [[ -z "$(pgrep ii)" ]]
  then
    "$connect"
  else
    echo 'Warning: ii already running, kill $(ps aux | awk '/connect/')'
    return 1
  fi

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

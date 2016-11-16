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

  local noautojoin="${1:-}"
  if [[ -n "$noautojoin" ]]
  then
    networks="$noautojoin"
    shift
    channels="$@"
  else
    [[ -f "$ircdir/autojoin" ]] && source "$ircdir/autojoin" || {
      echo "Not found: $ircdir/autojoin"
    }
  fi

  if [[ -n "$(pgrep ii)" ]]
  then
    echo 'Warning: ii already running, kill $(ps aux | awk '/connect/')'
  fi

  local opts= hist=50
  for network in $networks
  do
    unset server channels
    if [[ -z "$noautojoin" ]]
    then
      "$network"
      "$connect"
    else
      echo "server=$noautojoin channels=$channels" "$connect"
      env "server=$noautojoin channels=$channels" "$connect"
    fi
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

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

custom_network() {
  server="$1"
  shift
  channels="$@"
}

irc() {
  # local args=("$@")
  local connect="$ircbin/connect"
  local iii="$ircbin/iii"
  has tmux && iii="$ircbin/tmiii"

  if [[ "$#" -gt 0 ]]
  then
    networks="custom_network"
  else
    [[ -f "$ircdir/autojoin" ]] && source "$ircdir/autojoin" || {
      echo "Not found: $ircdir/autojoin"
    }
  fi

  local hist=50
  for network in $networks
  do
    unset server channels

    "$network" "$@"
    local pattern="connect\s$server" #.*${channels[@]}
    local ps="$(ps -A ux | awk "/$pattern/ {print \$2}")"
    if [[ -z "$ps" ]]
    then
      "$connect" "$server" "$channels"
    else
      # echo "Warning: already running, pkill ii or kill -9 \$(ps -A ux | awk '/$pattern/ {print \$2}')"
      printf "/j %s\n" $channels > "$ircdir/$server/in"
    fi

    local opts="h=$hist n=$server"
    # [[ -z "$channels" ]] &&
    env $opts "$iii"
    for channel in $channels
    do
      opts+=" c=$channel"
      env $opts "$iii"
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

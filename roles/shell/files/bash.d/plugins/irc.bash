# IRC

ircdir="$HOME/irc"
ircbin="${ircbin:-$ircdir/bin}"

custom_network() {
  server="$1"
  shift
  channels=("$@")
}

irc() {
  # Parse arguments
  case "$@" in
    -n" "*) # nick
      shift
      n="$1"
      shift
      ;;
  esac
  local args=("$@")
  local connect="$ircbin/connect"
  local iii="$ircbin/iii"
  has tmux && iii="$ircbin/tmiii"
  [[ -e "$iii" ]] || {
    echo "Not found: $iii"
    return 1
  }

  if [[ "$#" -gt 0 ]]
  then
    networks="custom_network"
  else
    [[ -f "$ircdir/autojoin" ]] && source "$ircdir/autojoin" || {
      echo "Not found: $ircdir/autojoin"
    }
  fi

  local hist= nick="${n:=$USER}"
  for network in $networks
  do
    unset server channels

    "$network" "${args[@]}"
    local pattern="connect\s$server" #.*${channels[@]}
    local ps="$(ps -A ux | awk "/$pattern/ {print \$2}")"
    if [[ -z "$ps" ]]
    then
      USER="$nick" "$connect" "$server" "$channels"
    else
      # echo "Warning: already running, pkill ii or kill -9 \$(ps -A ux | awk '/$pattern/ {print \$2}')"
      printf "/j %s\n" $channels > "$ircdir/$server/in"
    fi

    local opts="h=$hist n=$nick s=$server"
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

weechat() {
  IRC="weechat"
  [[ -n "$TMUX" ]] && TERM=screen-256color "$IRC" "$@" || "$IRC" "$@"
}

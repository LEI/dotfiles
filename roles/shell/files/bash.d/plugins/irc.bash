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

  for network in $networks
  do
    local hist= nick="${n:=$USER}"
    unset server port channels
    "$network" "${args[@]}"

    if [[ "$server" =~ .*:[0-9]+ ]]
    then
      port="${server#*:}"
      server="${server%%:*}"
    fi

    local pattern="connect\s$server" #.*${channels[@]}
    local ps="$(ps -A ux | awk "/$pattern/ {print \$2}")"
    if [[ -z "$ps" ]]
    then
      USER="$nick" "$connect" "$server" "${channels[@]}" # & wait "$!"
      sleep 1
      # # Wait for NickServ identification
      # while ! test -f "$ircdir/$server/nickserv/out"
      # do sleep .3; done

      # (tail -f "$ircdir/$server/nickserv/out" & echo $! >&3) 3>tpid | while read line
      # do case "$line" in *identified*$nick*) kill $(<tpid) ;; esac
      # done
    elif [[ -n "$channels" ]]
    then
      echo "Warning: connect already running" # pkill ii or kill -9 \$(ps -A ux | awk '/$pattern/ {print \$2}')
      printf "/j %s\n" "${channels[@]}" > "$ircdir/$server/in"
    fi

    local opts="h=$hist n=$nick s=$server p=$port"
    # [[ -z "$channels" ]] &&
    env $opts "$iii"
    for channel in "${channels[@]}"
    do
      while ! test -f "$ircdir/$server/$channel/out"
      do sleep .3; done
      local chanopts="$opts c=$channel"
      env $chanopts "$iii"
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

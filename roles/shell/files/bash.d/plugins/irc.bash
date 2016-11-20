# IRC

ircdir="$HOME/irc"

custom_network() {
  server="$1"
  shift
  channels=("$@")
}

kirc() {
  local ps="$(ps ux -A | awk '/\/bin\/connect|notifii[i]/ {print $2}')"
  if [[ -n "$ps" ]]
  then kill -9 $ps; pkill ii
  fi
}

irc() {
  # Parse arguments
  while true
  do
    case "$@" in
      -n\ *) shift; n="$1"; shift ;;
      --ssl\ *) shift; secure=1 ;;
      *) break ;;
    esac
  done

  local args=("$@")
  local connect="$ircdir/bin/connect"

  local iii="$ircdir/bin/iii"
  has tmux && iii="$ircdir/bin/tmiii"
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
    local hist= nick="${n:=$USER}" ssl="${secure-:}" # l=sb r=eb
    unset server port channels
    "$network" "${args[@]}"

    if [[ "$server" =~ .*:[0-9]+ ]]
    then
      port="${server#*:}"
      server="${server%%:*}"
    fi

    local opts="h="$hist" n="$nick" s="$server" p="$port"" # l="$l" r="$r"

    local pattern="connect\s$server" #.*${channels[@]}
    local ps="$(ps -A ux | awk "/$pattern/ {print \$2}")"
    if [[ -z "$ps" ]]
    then
      USER="$nick" ssl="$ssl" "$connect" "$server" "${channels[@]}" # & wait "$!"
      sleep 1
    elif [[ -n "$channels" ]]
    then
      echo "Warning: connect already running for $server"
      [[ -n "$channels" ]] && printf "/j %s\n" ${channels[@]} > "$ircdir/$server/in"
    fi

    # Notify
    local notifiii="$ircdir/bin/notifiii"
    if [[ -x "$notifiii" ]]
    then
      local notifps="$(ps -A ux | awk '/[notifii[i]/ {print $2}')"
      if [[ -z "$notifps" ]]
      then
        env $opts "$notifiii" &>/dev/null &
        # notifpid="$!" # TODO kill pid
      fi
    fi

    while ! test -p "$ircdir/$server/in"
    do sleep .3; done
    env $opts "$iii"

    if [[ -n "$channels" ]]
    then
      for channel in "${channels[@]}"
      do
        while ! test -f "$ircdir/$server/$channel/out"
        do sleep .3; done
        local chanopts="$opts c=$channel"
        env $chanopts "$iii"
      done
    fi
  done
  # [[ -n "${notifpid:-}" ]] && kill "$notifpid"
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
  if [[ -n "$TMUX" ]]
  then
    TERM=screen-256color "$IRC" "$@"
  else
    "$IRC" "$@"
  fi
}

# IRC

ircdir="${ircdir:-$HOME/irc}"

irc_network() {
  if [[ "$1" == *"@"* ]]
  then nick="${1%%@*}" server="${1#*@}"
  else server="$1"
  fi
  shift
  channels=("$@")
}

irc_kill() {
  local ps="$(ps ux -A | awk '/\/bin\/connect|bash.*\/bin\/iii|notifii[i]/ {print $2}')"
  if [[ -n "$ps" ]]
  then kill -9 $ps; pkill ii; pkill inotifywait
  fi
}

# declare -A irc_servers=()
# irc_add() { local host="$1" pid="$2" irc_servers["$host"]="$pid" }
# irc_list() { echo "${irc_servers[@]}" }

irc() {
  if [[ -d "$ircdir" ]]
  then cd "$ircdir"
  else die "$ircdir: No such directory"
  fi

  local iii="$ircdir/bin/iii"
  has tmux && iii="$ircdir/bin/tmiii"
  local connect="$ircdir/bin/connect"
  if ! executable "$iii" || ! executable "$connect"
  then return 1
  fi

  # Parse arguments
  local secure=1
  while true
  do
    case "$@" in
      # -n\ *) shift; n="$1"; shift ;;
      --no-ssl\ *) shift; secure=0 ;;
      -*) die "$1: Invalid argument" ;;
      *) break ;;
    esac
  done

  local args=("$@")
  if [[ "$#" -gt 0 ]]
  then networks="irc_network"
  elif [[ -f "$ircdir/autojoin" ]]
  then source "$ircdir/autojoin"
  else die "$ircdir/autojoin: No such file"
  fi

  for network in $networks
  do unset server port channels nick ssl
    local hist=100 nick="${n:=$USER}" # l=sb r=eb
    "$network" "${args[@]}" # Set the appropriate vars
    if [[ "$server" =~ .*:[0-9]+ ]]
    then port="${server#*:}" server="${server%%:*}"
    fi

    local opts="h="$hist" n="$nick" s="$server" p="$port"" # l="$l" r="$r"
    local lock="$nick@$server:$port"

    # Connect to the server
    [[ "$secure" -gt 0 ]] || [[ -n "$ssl" ]] && ssl="ssl"
    local connectopts="icrdir="$ircdir" nick="$nick" server="$server" port="$port" secure="$ssl""
    # while read line <&3
    # do echo "test: $line" > ~/test.log
    # done < <(setlock -nX "/tmp/$server.lockfile" nohup env $connectopts "$connect" "${channels[@]}") &
    setlock -nX "/tmp/$lock.lockfile" nohup env $connectopts "$connect" "${channels[@]}" &
    # local connectpid="$!"
    sleep 1

    # Notify # local notifps="$(ps -A ux | awk '/notifii[i]/ {print $2}')"
    local notifiii="$ircdir/bin/notifiii"
    if [[ -x "$notifiii" ]] && has inotifywait
    then setlock -nX "/tmp/$lock.notifiii.lockfile" nohup env $opts "$notifiii" &
    fi

    # while ! test -f "$ircdir/$server/out"
    log "Waiting for $server..."
    while ! test -p "$ircdir/$server/in"
    do sleep .3; done

    env $opts "$iii"
    local serverpid="$!"
    # wait "$serverpid" && echo "$serverpid -> $(jobs -l)" &

    # Join channels
    if [[ -n "$channels" ]]
    then
      # printf "/j %s\n" ${channels[@]} > "$ircdir/$server/in"
      for channel in $channels # ${channels[@]}
      do
        log "Waiting for $channel@$server..."
        while ! test -f "$ircdir/$server/$channel/out"
        do sleep .3; done
        local chanopts="$opts c=$channel"
        env $chanopts "$iii" # &
      done
    fi
  done
}

executable() {
  local path="$1"
  if [[ ! -e "$path" ]]
  then error "$path: No such file"
  elif [[ ! -x "$path" ]]
  then error "$path: Not executable"
  else return 0
  fi
  return 1
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

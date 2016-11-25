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
  local ps="$(ps ux -A | awk '/bash.*\/bin\/connect|ii [-]|notifii[i]/ {print $2}')"
  if [[ -n "$ps" ]]
  then kill $ps; pkill ii # pkill inotifywait
  fi
}

# declare -A irc_servers=()
# irc_add() { local host="$1" pid="$2" irc_servers["$host"]="$pid" }
# irc_list() { echo "${irc_servers[@]}" }

irc() {
  if [[ ! -d "$ircdir" ]]
  then die "$ircdir: No such directory"
  # else cd "$ircdir"
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
    local pidfile="/tmp/$lock.pid"

    # Connect to the server
    log "Connecting to $server"
    [[ "$secure" -gt 0 ]] || [[ -n "$ssl" ]] && ssl="ssl"
    local connectopts="icrdir="$ircdir" nick="$nick" server="$server" port="$port" secure="$ssl""
    # while read line <&3; do echo "test: $line" > ~/test.log
    # done < <(setlock -nX "/tmp/$server.lockfile" nohup env $connectopts "$connect" "${channels[@]}") &
    setlock -nX "/var/lock/$lock.connect.lock" nohup env $connectopts "$connect" "${channels[@]}" > "$ircdir/$server/connect.log" & disown
    [[ "$?" -eq 0 ]] && echo "$!" > "$pidfile"

    # if [[ -n "$(pgrep -F "$pidfile")" ]]; then pkill -F "$pidfile"; fi
    # [[ ! -f "$pidfile" ]] || [[ "$pid" != "$(cat "$pidfile")" ]]
    sleep 1

    # Notify # local notifps="$(ps -A ux | awk '/notifii[i]/ {print $2}')"
    local notifiii="$ircdir/bin/notifiii"
    if [[ -x "$notifiii" ]] && has inotifywait
    then setlock -nX "/var/lock/$lock.notifiii.lock" nohup env $opts "$notifiii" > "$ircdir/$server/notify.log" & disown
      [[ "$?" -eq 0 ]] && echo "$!" >> "$pidfile"
    fi

    # while ! test -f "$ircdir/$server/out"
    while ! test -p "$ircdir/$server/in"
    do sleep .3; done

    env $opts "$iii"
    # local serverpid="$!"
    # wait "$serverpid" && echo "$serverpid -> $(jobs -l)" &

    # Join channels
    if [[ -n "$channels" ]]
    then
      # printf "/j %s\n" ${channels[@]} > "$ircdir/$server/in"
      for channel in $channels # ${channels[@]}
      do
        log "Joining $channel@$server..."
        while ! test -f "$ircdir/$server/$channel/out"
        do sleep .3; done
        local chanopts="$opts c=$channel goto=false"
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

# # http://www.kfirlavi.com/blog/2012/11/06/elegant-locking-of-bash-program/
# lock() {
#   local prefix="$1"
#   local fd="${2:-1337}"
#   local lockfile="/var/lock/$prefix.lock"
#   eval "exec $fd>$lockfile"
#   if flock -n "$fd"
#   then return 0
#   else return 1
#   fi
# }

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

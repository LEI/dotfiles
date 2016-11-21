# IRC

ircdir="$HOME/irc"

custom_network() {
  server="$1"
  shift
  channels=("$@")
}

kirc() {
  local ps="$(ps ux -A | awk '/\/bin\/connect|bash.*\/bin\/iii|notifii[i]/ {print $2}')"
  if [[ -n "$ps" ]]
  then kill -9 $ps; pkill ii
  fi
}

irc() {
  # Parse arguments
  local secure=1
  while true
  do
    case "$@" in
      -n\ *) shift; n="$1"; shift ;;
      --no-ssl\ *) shift; secure=0 ;;
      -*) echo "Invalid argument: $1"; return 1 ;;
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
    local hist=100 nick="${n:=$USER}" # l=sb r=eb
    unset server port channels
    "$network" "${args[@]}" # Set the appropriate vars

    if [[ "$server" =~ .*:[0-9]+ ]]
    then
      port="${server#*:}"
      server="${server%%:*}"
    fi

    local opts="h="$hist" n="$nick" s="$server" p="$port"" # l="$l" r="$r"

    # local pattern="connect\s$server" #.*${channels[@]}
    # local ps="$(ps -A ux | awk "/$pattern/ {print \$2}")"
    # if [[ -z "$ps" ]]
    # connectpid="$!"
    # echo "$connectpid" > "/tmp/$server.pid"
    # sleep 1 # wait "$connectpid"
    # echo "Warning: connect already running for $server"

    # Connect to the server
    [[ "$secure" -gt 0 ]] || [[ -n "$ssl" ]] && ssl="ssl"
    local conopts="nick="$nick" server="$server" port="$port" secure="$ssl""
    setlock -nX "/tmp/$server.lockfile" env $conopts "$connect" "${channels[@]}" &>/dev/null
    sleep 1

    # Notify # local notifps="$(ps -A ux | awk '/notifii[i]/ {print $2}')"
    local notifiii="$ircdir/bin/notifiii"
    if [[ -x "$notifiii" ]] && has inotifywait
    then setlock -nX "/tmp/notifiii.lockfile" env $opts "$notifiii" &>/dev/null &
    fi

    # while ! test -f "$ircdir/$server/out"
    # echo "Waiting for $server..."
    while ! test -p "$ircdir/$server/in"
    do sleep .3; done

    env $opts "$iii"
    # serverpid="$!"

    # Join channels
    if [[ -n "$channels" ]]
    then
      # printf "/j %s\n" ${channels[@]} > "$ircdir/$server/in"
      for channel in "${channels[@]}"
      do
        # echo "Waiting for $server $channel..."
        while ! test -f "$ircdir/$server/$channel/out"
        do sleep .3; done
        local chanopts="$opts c=$channel"
        env $chanopts "$iii"
      done
    fi
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
  if [[ -n "$TMUX" ]]
  then
    TERM=screen-256color "$IRC" "$@"
  else
    "$IRC" "$@"
  fi
}

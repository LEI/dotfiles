#!/usr/bin/env sh

: "${ircdir:=$HOME/irc}"
: "${nick:=$USER}"

[ -f "$ircdir/autojoin" ] && . "$ircdir/autojoin"

# Some privacy please, thanks
chmod 700 "$ircdir"
chmod 600 "$ircdir"/*/ident &>/dev/null

for network in $networks; do
  unset server channels port
  "$network" # Set the appropriate vars

  while true; do
    # Cleanup
    rm -f "$ircdir/$server/in"

    # Connect to network -- password is set through the env var synonym to the network name
    # iim -i "$ircdir" -n "$nick" -k "$network" -s "$server" -p "${port:-6667}" &
    ii -i "$ircdir" -n "$nick" -k "$network" -s "$server" -p "${port:-6667}" &
    pid="$!"

    # Wait for the connection
    while ! test -p "$ircdir/$server/in"; do sleep .3; done

    # Auth to services
    if [ -e "$ircdir/$server/ident" ]
    then printf "/j nickserv identify %s\n" "$(cat "$ircdir/$server/ident")" > "$ircdir/$server/in"
    fi && rm -f "$ircdir/$server/nickserv/out" # Clean that up - ident passwd is in there

    # Join channels
    printf "/j %s\n" $channels > "$ircdir/$server/in"

    # If connection is lost reconnect
    wait "$pid"
  done &
done


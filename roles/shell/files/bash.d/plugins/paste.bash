# Paste bin
# ~/bin/pb

PB_CURL_OPTS="-s"

# Copy the url of the uploaded paste
pbx() {
  local copy
  if hash xsel 2>/dev/null
  then copy="xsel -l /dev/null -b"
  # elif xclip[board]
  elif hash pbcopy 2>/dev/null
  then copy="pbcopy" # -pboard general
  else error "pbx: No clipboard tool found ($(uname -s))"; return 1
  fi
  local args="--render $@" # --handler=r $@" # ?r=1
  local curl_opts="$PB_CURL_OPTS -w %{redirect_url} -o /dev/stderr"
  PB_CURL_OPTS="$curl_opts" pb $args | "$copy"
  # curl -sF "c=@${1:--}" -w "%{redirect_url}" 'http://ptpb.pw/?r=1' -o /dev/stderr | "$copy"
}

# Encrypt file with GPG symetric cipher
pbg() { # Decrypt with curl <pasteurl> | gpg -d
  gpg -o - -c "$1" | pbx -C # $@
}

# Capture screenshot
pbs () {
  local win="${1:-root}"
  local tmp=/tmp/$$.png
  gm import -window $win $tmp
  pbx $tmp
}

# Record terminal
pbs () {
  local tmp=/tmp/$$.json
  asciinema rec $tmp
  pbx $tmp
}

# Pastebin
# http://ptpb.pw/#shell-functions

pb() {
  # expiry: -F sunset=120
  # private: -F p=1
  # vanity: http://ptpb.pw/~slug$
  curl -F "c=@${1:--}" -F sunset=60 http://ptpb.pw/
}

# Copy the url of the uploaded paste
pbx() {
  local copy
  if has xsel
  then copy="xsel -l /dev/null -b"
  # elif has xclip # xclipboard
  # elif has pbcopy
  else error "No clipboard manager found"
    return 1
  fi
  curl -sF "c=@${1:--}" -w "%{redirect_url}" 'http://ptpb.pw/?r=1' -o /dev/stderr | "$copy"
}

# Capture screenshot
pbs () {
  gm import -window ${1:-root} /tmp/$$.png
  pbx /tmp/$$.png
}

# Record terminal
pbs () {
  asciinema rec /tmp/$$.json
  pbx /tmp/$$.json
}

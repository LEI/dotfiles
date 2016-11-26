# Pastebin
# http://ptpb.pw/#shell-functions

pb() {
  curl -F "c=@${1:--}" http://ptpb.pw/
}

# Copy the url of the uploaded paste
pbx() {
  local copy
  if has xsel
  then copy="xsel -l /dev/null -b"
  # elif has xclip # xclipboard
  # elif has pbcopy
  else error "No clipboard manager"
    return 1
  fi
  curl -sF "c=@${1:--}" -w "%{redirect_url}" 'http://ptpb.pw/?r=1' -o /dev/stderr | "$copy"
}
pbs () {
  gm import -window ${1:-root} /tmp/$$.png
  pbx /tmp/$$.png
}

pbs () {
  asciinema rec /tmp/$$.json
  pbx /tmp/$$.json
}

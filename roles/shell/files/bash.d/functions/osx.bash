# OS X functions
# https://github.com/Bash-it/bash-it/blob/master/plugins/available/osx.plugin.bash
# https://github.com/herrbischoff/awesome-osx-command-line/blob/master/functions.md

[[ "$(uname -s)" == "Darwin" ]] || return

preview() {
  "$@" | open -fa $PREVIEW
}

# Download and preview a file
pcurl() {
  preview curl "$*"
}

# Man preview
pman() {
  preview man -t "$1"
}

# Ruby preview
pri() {
  preview ri -T "$1"
}

# Quick look file
ql() {
  qlmanage -p "$1" >& /dev/null
}

cdf() {
  # tell app 'Finder' to POSIX path of (insertion location as alias)
  target="$(osascript -e 'tell application "Finder" to if (count of Finder windows) > 0 then get POSIX path of (target of front Finder window as text)')"
  if [[ -n "$target" ]]; then
    cd "$target"; pwd
  else
    echo "No Finder window found" >&2
  fi
}

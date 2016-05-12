# OS X functions
# https://github.com/Bash-it/bash-it/blob/master/plugins/available/osx.plugin.bash

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

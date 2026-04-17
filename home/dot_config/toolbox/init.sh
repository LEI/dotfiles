toolbox() {
  if [ "$#" -eq 0 ]; then
    set -- enter "$(basename "$PWD")"
  elif [ "$1" = "l" ] || [ "$1" = "ls" ]; then
    shift
    set -- list "$@"
  fi
  command toolbox "$@"
}
alias tb=toolbox

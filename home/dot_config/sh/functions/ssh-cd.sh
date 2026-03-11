ssh-cd() {
  local host="${1:?host required}" dir="${2:?dir required}" qdir
  shift 2
  qdir=$(printf '%q' "$dir")
  if [ $# -eq 0 ]; then
    ssh -t "$host" "cd $qdir && exec \$SHELL -l"
  else
    ssh -t "$host" "cd $qdir && $*"
  fi
}

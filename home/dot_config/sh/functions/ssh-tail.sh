ssh-tail() {
  local host="${1:?host required}" dir="${2:?dir required}" cmd="${3:?cmd required}" fmt="${4:-cat}"
  ssh "$host" "cd $(printf '%q' "$dir") && $cmd" | $fmt
}

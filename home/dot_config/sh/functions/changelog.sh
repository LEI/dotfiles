# TODO: replace by git alias or plugin
# Show changes since last pull
# Usage: changelog [diff]
changelog() {
  local cmd="$1"
  shift
  newline=$'\n'
  reflog="$(git reflog | grep -A1 pull | head -2 | cut -d' ' -f1)"
  case "$cmd" in
  diff) git diff "$@" "${reflog//$newline/..}" ;;
  '' | *) git log --oneline "${reflog//*$newline/}~1..${reflog//$newline*/}" ;;
  esac
}

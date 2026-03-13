compose_project() {
  local dir="${1:?dir required}"
  shift
  local provider="${COMPOSE_PROJECT_PROVIDER:?set COMPOSE_PROJECT_PROVIDER}"
  if [ $# -eq 0 ]; then
    echo >&2 "+ $provider compose --project-directory=$dir up --build --detach"
    $provider compose --project-directory="$dir" up --build --detach
    set -- logs --follow --since=1m
  fi
  echo >&2 "+ $provider compose --project-directory=$dir $*"
  $provider compose --project-directory="$dir" "$@"
}

#!/bin/bash

pi_compose() {
  # local dir="$PWD"
  # dir="${dir#$HOME/}"
  # dir="${dir//\/./-}"
  local name
  name="workspace-$(basename "$PWD")-$(echo "${PWD}" | sha1sum | cut -c1-8)"
  # shellcheck disable=SC2295
  export WORKSPACE="/workspace/${PWD/$HOME/~}"
  docker compose \
    --project-directory="$HOME/.config/pi/container" \
    --project-name="$name" \
    "$@"
}

# Rebuild and start the container in detached mode by default
pi_up() {
  if [ $# -eq 0 ]; then
    set -- --build --detach
  fi
  pi_compose up "$@" # --quiet-build --quiet-pull
}

pi_attach() {
  echo >&2 "Detach with ^P^Q"
  pi_compose attach pi "$@"
}

# Execute a command in the running container
pi_exec() {
  # pi_compose exec -it pi bash -c "$*"
  pi_compose exec -it pi "$@"
}

pi_down() {
  pi_compose down "$@"
}

# Start the container and continue session
pi() {
  # pi_up --detach && pi_exec mise exec -- pi --continue "$@"
  if pi_up --detach || pi_up --build --detach; then
    if [ $# -gt 0 ]; then
      pi_exec "$@"
      pi_exec /entrypoint.sh "$@"
    else
      pi_attach --index 0
    fi
  fi
}

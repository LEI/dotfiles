#!/bin/bash

pi_local() {
  bunx @mariozechner/pi-coding-agent@0.52.9 "$@"
}

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

# Rebuild and start detached by default
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

# Execute in the running container
pi_exec() {
  # pi_compose exec -it pi bash -c "$*"
  pi_compose exec -it pi "$@"
}

pi_down() {
  pi_compose down "$@"
}

# Start or continue session
pi() {
  pi_up --detach
  if [ $# -eq 0 ]; then
    set -- --continue
  fi
  # NOTE: this ensures per project mise.toml is ignored
  pi_exec mise exec node@lts -- pi "$@"
  # if [ $# -gt 0 ]; then
  #   pi_exec pi "$@"
  # else
  #   pi_attach --
  # fi
}

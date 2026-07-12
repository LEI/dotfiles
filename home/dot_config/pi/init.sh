# shellcheck shell=bash

pi-local() {
  local pi_version="${PI_VERSION:-latest}"
  bunx "@mariozechner/pi-coding-agent@$pi_version" "$@"
}

pi-compose() {
  local name provider
  name="workspace-$(basename "$PWD")-$(echo "${PWD}" | sha1sum | cut -c1-8)"
  provider="${CONTAINER_PROVIDER:?}"
  # shellcheck disable=SC2295
  local home
  home="$(realpath "$HOME")"
  export WORKSPACE="/workspace/${PWD#"$home/"}"
  $provider compose \
    --project-directory="$HOME/.config/pi/container" \
    --project-name="$name" \
    "$@"
}

# Rebuild and start detached by default
pi-up() {
  if [ $# -eq 0 ]; then
    set -- --build --detach
  fi
  pi-compose up "$@" # --quiet-build --quiet-pull
}

pi-attach() {
  echo "Detach with ^P^Q" >&2
  pi-compose attach pi "$@"
}

# Execute in the running container
pi-exec() {
  pi-compose exec -it pi "$@"
}

pi-down() {
  pi-compose down "$@"
}

# Start or continue session
pi() {
  pi-up --detach
  if [ $# -eq 0 ]; then
    set -- --continue
  fi
  # NOTE: this ensures per project mise.toml is ignored
  pi-exec mise exec node@lts -- pi "$@"
  # if [ $# -gt 0 ]; then
  #   pi-exec pi "$@"
  # else
  #   pi-attach --
  # fi
}

# if command -v pi >/dev/null; then
#   pi() { env pi "${@:---continue}"; }
# fi

# Ephemeral: no persistent container, slower startup, simpler
pi-run() {
  local home
  home="$(realpath "$HOME")"
  local workspace="/workspace/${PWD#"$home/"}"
  ${CONTAINER_PROVIDER:?} run --rm -it \
    --userns=keep-id \
    -v "$HOME/.config/pi/agent:/home/coder/.pi/agent:Z" \
    -v "$PWD:$workspace:Z" \
    -w "$workspace" \
    pi-agent:latest \
    pi "${@:---continue}"
}

# Built-in sandbox extension: isolates tool calls in Alpine, Pi runs on host
# Requires: sandbox extension enabled, sandbox container pre-created
# pi's --sandbox accepts docker:<name>; podman is a supported sandbox runtime upstream
pi-sandbox() {
  pi-local --sandbox="${CONTAINER_PROVIDER:?}:pi-sandbox" "${@:---continue}"
}

# devcontainer CLI (MIT): open spec, podman support via --docker-path
# Requires: bunx @devcontainers/cli, devcontainer.json in container dir
pi-devcontainer() {
  local cfg="$HOME/.config/pi/container/devcontainer.json"
  bunx --bun @devcontainers/cli up --workspace-folder . --config "$cfg" --docker-path "${CONTAINER_PROVIDER:-docker}"
  bunx --bun @devcontainers/cli exec --workspace-folder . --config "$cfg" pi "${@:---continue}"
}

# sbx (BSL): full isolation, macOS-first; x86_64 Linux needs rpm extraction
# Build: pi-sbx-build; push to a registry before first run
pi-sbx-build() {
  "${CONTAINER_PROVIDER:?}" build \
    --file "$HOME/.config/pi/container/Dockerfile.sbx" \
    --tag ghcr.io/lei/pi:latest \
    "$HOME/.config/pi/container"
}

pi-sbx() {
  sbx run --template ghcr.io/lei/pi:latest shell -- pi "${@:---continue}"
}

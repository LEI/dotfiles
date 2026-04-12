pi_local() {
  local pi_version="${PI_VERSION:-latest}"
  bunx "@mariozechner/pi-coding-agent@$pi_version" "$@"
}

pi_compose() {
  local name provider
  name="workspace-$(basename "$PWD")-$(echo "${PWD}" | sha1sum | cut -c1-8)"
  provider="${CONTAINER_PROVIDER:?}"
  # shellcheck disable=SC2295
  local _home
  _home="$(realpath "$HOME")"
  export WORKSPACE="/workspace/${PWD#"$_home/"}"
  $provider compose \
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

# if command -v pi >/dev/null; then
#   pi() { env pi "${@:---continue}"; }
# fi

# Ephemeral: no persistent container, slower startup, simpler
pi_run() {
  local _home
  _home="$(realpath "$HOME")"
  local workspace="/workspace/${PWD#"$_home/"}"
  ${CONTAINER_PROVIDER:?} run --rm -it \
    --userns=keep-id \
    -v "$HOME/.config/pi/agent:/home/coder/.pi/agent:Z" \
    -v "$PWD:$workspace:Z" \
    -w "$workspace" \
    pi-agent:latest \
    pi "${@:---continue}"
}

# Built-in sandox extension: isolates tool calls in Alpine, Pi runs on host
# Requires: sandox extension enabled, sandbox container pre-created
pi_sandox() {
  pi_local --sandbox=docker:pi-sandbox "${@:---continue}"
}

# devcontainer CLI (MIT): open spec, podman support via --docker-path
# Requires: bunx @devcontainers/cli, devcontainer.json in container dir
pi_devcontainer() {
  local cfg="$HOME/.config/pi/container/devcontainer.json"
  bunx --bun @devcontainers/cli up --workspace-folder . --config "$cfg" --docker-path "${CONTAINER_PROVIDER:-docker}"
  bunx --bun @devcontainers/cli exec --workspace-folder . --config "$cfg" pi "${@:---continue}"
}

# sbx (BSL): full isolation, macOS-first; x86_64 Linux needs rpm extraction
# Build: pi_sbx_build; push to a registry before first run
pi_sbx_build() {
  docker build \
    --file "$HOME/.config/pi/container/Dockerfile.sbx" \
    --tag ghcr.io/lei/pi:latest \
    "$HOME/.config/pi/container"
}

pi_sbx() {
  sbx run --template ghcr.io/lei/pi:latest shell -- pi "${@:---continue}"
}

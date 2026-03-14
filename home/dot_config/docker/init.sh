if command -v docker >/dev/null; then
  export CONTAINER_PROVIDER=docker
fi

if command -v lazydocker >/dev/null; then
  alias D=lazydocker
elif command -v oxker >/dev/null; then
  alias D=oxker
fi

if command -v podman-tui >/dev/null; then
  alias P=podman-tui
fi

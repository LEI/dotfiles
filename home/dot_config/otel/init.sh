export OTEL_CONFIG_DIR="${OTEL_CONFIG_DIR:-$HOME/.config/otel}"
# systemctl --user start podman.socket

otel() { compose_project "${OTEL_CONFIG_DIR}" "$@"; }

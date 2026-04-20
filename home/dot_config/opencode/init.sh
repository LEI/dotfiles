# TODO: ../private_secrets.d/private_opencode.conf.tmpl
export OPENCODE_URL="https://opencode.test" # http://localhost:4096
export OPENCODE_EXPERIMENTAL=true
export OPENCODE_EXPERIMENTAL_LSP_TOOL=true

# FIXME: disable auto loading
# https://github.com/anomalyco/opencode/blob/dev/packages/opencode/src/flag/flag.ts
export OPENCODE_DISABLE_CLAUDE_CODE=true
export OPENCODE_DISABLE_CLAUDE_CODE_PROMPT=true
export OPENCODE_DISABLE_CLAUDE_CODE_SKILLS=true
export OPENCODE_DISABLE_EXTERNAL_SKILLS=true

opencode() {
  # command opencode "${@:---continue}"
  if [ $# -eq 0 ]; then
    # https://github.com/anomalyco/opencode/issues/17322
    if curl --silent "$OPENCODE_URL" >/dev/null; then
      echo "Attaching to server: $OPENCODE_URL" >&2
      set -- attach "$OPENCODE_URL" "$@"
    fi
    set -- "$@" --continue
  fi
  command opencode "$@"
}
alias oc=opencode

# # openwork start --workspace /path/to/your/workspace --approval auto
# openwork_daemon() {
#   port=4096
#   if ! command openwork daemon status --opencode-port=$port; then
#     command openwork serve --detach --opencode-port=$port
#   fi
#   # echo >&2 opencode attach http://127.0.0.1:$port "$@"
# }
# # Log-only mode: openwork serve or start --no-tui
# openwork_serve() {
#   command openwork serve "$@"
# }
# # Smoke checks
# openwork_check() {
#   command openwork start --check --check-events "$@"
# }
# Snadbox mode: auto|docker|container
# --sandbox auto --sandbox-mount "/path/on/host:datasets:ro"
alias ow=openwork

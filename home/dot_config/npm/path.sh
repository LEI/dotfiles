# shellcheck shell=sh

if [ -n "${npm_config_prefix:-}" ]; then
  pathmunge "$npm_config_prefix/bin"
fi
if [ -n "${PNPM_HOME:-}" ]; then
  pathmunge "$PNPM_HOME"
fi

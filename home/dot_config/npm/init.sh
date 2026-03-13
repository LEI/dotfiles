if [ -d "$HOME/.node_modules/bin" ]; then
  pathmunge "$HOME/.node_modules/bin" after
fi
# if [ ! -d "$npm_config_prefix" ]; then
#   mkdir -p "$npm_config_prefix"
# fi
if [ -n "${npm_config_prefix:-}" ] && [ -d "$npm_config_prefix/bin" ]; then
  pathmunge "$npm_config_prefix/bin"
fi
if [ -n "${PNPM_HOME:-}" ] && [ -d "$PNPM_HOME" ]; then
  pathmunge "$PNPM_HOME"
fi

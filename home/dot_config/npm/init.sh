# shellcheck shell=sh

# https://github.com/b3nj5m1n/xdg-ninja/tree/main/programs
# https://github.com/twpayne/dotfiles/blob/master/home/dot_zshrc.tmpl

# if ! [ -d "${PNPM_HOME:-}" ]; then
#   mkdir -p "$PNPM_HOME"
# fi
# if ! [ -d "${npm_config_prefix:-}" ]; then
#   mkdir -p "$npm_config_prefix"
# fi

if [ -d "$HOME/.node_modules/bin" ]; then
  pathmunge "$HOME/.node_modules/bin" after
fi
if [ -n "${npm_config_prefix:-}" ] && [ -d "$npm_config_prefix/bin" ]; then
  pathmunge "$npm_config_prefix/bin" replace
fi
if [ -n "${PNPM_HOME:-}" ] && [ -d "$PNPM_HOME" ]; then
  pathmunge "$PNPM_HOME" replace
fi

# Prepend to PATH
# pathmunge /usr/local/sbin

# Append ~/bin
pathmunge "$HOME/bin" after

# Composer packages
if hash composer 2>/dev/null; then
  # COMPOSER_HOME="$HOME/.composer"
  # COMPOSER_BIN_DIR="vendor/bin"
  # pathmunge "$COMPOSER_HOME/$COMPOSER_BIN_DIR" after
  pathmunge "$(composer config -g home)/$(composer config -g bin-dir)" after
fi

# NodeJS modules
if hash npm 2>/dev/null; then
  pathmunge "$HOME/.node_modules/bin" after
  # if [[ -z "${NODE_MODULES_PATH:-}" ]]; then
  #   export NODE_MODULES_PATH="$(npm config get prefix)/bin"
  # fi
  # pathmunge "$NODE_MODULES_PATH" after
fi

# Ruby gems
if hash ruby 2>/dev/null; then
  GEM_HOME="$(ruby -e 'print Gem.user_dir')"
  pathmunge "$GEM_HOME/bin" after
fi

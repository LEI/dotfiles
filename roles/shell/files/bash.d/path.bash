# Prepend to PATH
# pathmunge /usr/local/sbin

# Append ~/bin
if [[ -d "$HOME/bin" ]]; then
  pathmunge "$HOME/bin" after
fi

# Composer packages
if hash composer 2>/dev/null; then
  # pathmunge "$(composer config -g home)/$(composer config -g bin-dir)" after
  COMPOSER_HOME="$(composer config -g home)" # ~/.composer
  COMPOSER_BIN_DIR="$(composer config -g bin-dir)" # vendor/bin
  if [[ -d "$COMPOSER_HOME/$COMPOSER_BIN_DIR" ]]; then
    pathmunge "$COMPOSER_HOME/$COMPOSER_BIN_DIR" after
  fi
fi

# NodeJS modules
if hash npm 2>/dev/null; then
  pathmunge "$HOME/.node_modules/bin" after
  # if [[ -z "${NODE_MODULES_PATH-}" ]]; then
  #   NODE_MODULES_PATH="$(npm config get prefix)"
  # fi
  # pathmunge "$NODE_MODULES_PATH" after
fi

# Ruby gems
if hash ruby 2>/dev/null; then
  GEM_HOME="$(ruby -e 'print Gem.user_dir')"
  pathmunge "$GEM_HOME/bin" after
fi

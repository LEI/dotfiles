# Prepend to PATH
# pathmunge /usr/local/sbin

# Append ~/bin
if [[ -d "$HOME/bin" ]]
then
  pathmunge "$HOME/bin" after
fi

if [[ -d "/usr/local/sbin" ]]
then
  pathmunge "/usr/local/sbin" before
fi

# Composer packages
# FIXME PHP temp directory (/var/folders/x_/x/T) does not exist or is not writable to Composer. Set sys_temp_dir in your php.ini
if hash composer 2>/dev/null
then
  # pathmunge "$(composer config -g home)/$(composer config -g bin-dir)" after
  COMPOSER_HOME="$(composer config -g home 2>/dev/null)" # ~/.composer
  COMPOSER_BIN_DIR="$(composer config -g bin-dir 2>/dev/null)" # vendor/bin
  if [[ -d "$COMPOSER_HOME/$COMPOSER_BIN_DIR" ]]
  then
    pathmunge "$COMPOSER_HOME/$COMPOSER_BIN_DIR" after
  fi
fi

# NodeJS modules
if hash npm 2>/dev/null
then
  pathmunge "$HOME/.node_modules/bin" after
  # if [[ -z "${NODE_MODULES_PATH-}" ]]; then
  #   NODE_MODULES_PATH="$(npm config get prefix)"
  # fi
  # pathmunge "$NODE_MODULES_PATH" after
fi

# Ruby gems
if hash ruby 2>/dev/null
then
  export GEM_HOME="$(ruby -e 'print Gem.user_dir')" # GEM_PATH, BUNDLE_PATH
  pathmunge "$GEM_HOME/bin" after
fi

# Ruby env
if hash rbenv 2>/dev/null && [[ -z "${RBENV_SHIMS:-}" ]]
then # eval "$(rbenv init -)"
  export RBENV_SHELL=bash
  export RBENV_SHIMS="$HOME/.rbenv/shims"
  pathmunge "$RBENV_SHIMS"
  RBENV_BASH_COMPLETION="$(brew --cellar)/rbenv/$(rbenv --version | cut -d ' ' -f2)/completions/rbenv.bash"
  source "$RBENV_BASH_COMPLETION"
  command rbenv rehash 2>/dev/null
fi

# Go packages
if hash go 2>/dev/null
then
  export GOPATH="$HOME/go" # ~/Projects?
  # export GOROOT="$HOME/go"
  pathmunge "$GOPATH/bin" after
fi

#
# Pigmentize cat and less outputs
#

# https://github.com/Bash-it/bash-it/blob/master/plugins/available/less-pretty-cat.plugin.bash

if hash pygmentize 2>/dev/null; then
  # Get the full paths to binaries
  CAT_BIN=$(which cat)
  LESS_BIN=$(which less)

  # Runs either pygmentize or cat on each file passed in
  cat() {
    for var; do
      pygmentize "$var" 2>/dev/null || "$CAT_BIN" "$var";
    done
  }

  # Pigments the file passed in and passes it to less for pagination
  less() {
    pygmentize -g $* | "$LESS_BIN" -R
  }

  # most, ...
fi

# man() {
#   env \
#     LESS_TERMCAP_mb=$(printf "\e[1;31m") \
#     LESS_TERMCAP_md=$(printf "\e[1;31m") \
#     LESS_TERMCAP_me=$(printf "\e[0m") \
#     LESS_TERMCAP_se=$(printf "\e[0m") \
#     LESS_TERMCAP_so=$(printf "\e[1;44;33m") \
#     LESS_TERMCAP_ue=$(printf "\e[0m") \
#     LESS_TERMCAP_us=$(printf "\e[1;32m") \
#     man "$@"
# }

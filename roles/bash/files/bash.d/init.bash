#
# Bash init
#

if [[ -z "$DOT_BASH" ]]; then
  export DOT_BASH="$HOME/.bash.d"
fi

require() {
  for p in $@; do
    if [[ -r "$p" ]] && [[ -f "$p" ]]; then
      source "$p"
    else
      echo >&2 "Could not source $p"
      return 1 # exit 1
    fi
  done
  unset p
}

# Source the bash directories
require ${DOT_BASH}/{aliases,completion,lib,plugins,theme}/*.bash

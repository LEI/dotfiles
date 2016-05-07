#
# Bash init
#

if [[ -z "$DOT_BASH" ]]; then
  export DOT_BASH="$HOME/.bash.d"
fi

require() {
  for p in $@; do
    if [[ -f "$p" ]] && [[ -r "$p" ]]; then
      source "$p"
    else
      # echo >&2 "Could not source $p"
      return 1 # exit 1
    fi
  done
  unset p
}

# Source the bash directories
require ${DOT_BASH}/{aliases,completion,lib,plugins,theme}/*.bash

# ~/.exports can be used to export variables
# ~/.path can be used to extend '$PATH'.
# ~/.extra can be used for other settings you don’t want to commit.
require ~/.{exports,path,extra}

# for file in ~/.{colors,bash_plugins,bash_prompt,exports,extra,path}; do
#   [[ -r "$file" ]] && [[ -f "$file" ]] && source "$file"
# done
# unset file

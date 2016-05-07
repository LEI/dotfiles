#
# Bash loader
#

load() {
  for file in "$@"; do
    if [[ -r "$file" ]] && [[ -f "$file" ]]; then
      source "$file"
    # else
    #   echo >&2 "Could not source $file"
    fi
  done
  unset file
}

bash_load() {
  # Use the directory this file is stored if $DOT_BASH is not defined
  local directory="${DOT_BASH:-$(dirname "$BASH_SOURCE")}/$1"

  if [[ -d "$directory" ]]; then
    load $directory/*.bash
  else
    echo >&2 "Could not find $directory"
    return 1
  fi
}

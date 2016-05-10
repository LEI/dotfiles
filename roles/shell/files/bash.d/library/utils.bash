#
# Bash utils
#

source_dir() {
  for directory in "$@"; do
    if [[ -d "$directory" ]]; then
      source_files $directory/*
    else
      echo >&2 "Not a directory: $directory"
    fi
  done
  unset dir

}

source_files() {
  for file in "$@"; do
    source_file "$file"
  done
  unset file
}

source_file() {
  local file="$1"
  if [[ -r "$file" ]] && [[ -f "$file" ]]; then
    source "$file"
  # else
  #   echo >&2 "Not a file: $file"
  fi
}

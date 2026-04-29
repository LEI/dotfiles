# shellcheck shell=bash

# Source files and export their assignments
# Usage: export_env "$dir"/*.conf
#        export_env "$file1" "$file2"
export_env() {
  if [ $# -eq 0 ]; then
    return 0
  fi
  local _f _rc=0
  set -a
  for _f in "$@"; do
    if [ -f "$_f" ]; then
      # shellcheck disable=SC1090
      . "$_f" || _rc=$?
    fi
  done
  set +a
  return $_rc
}

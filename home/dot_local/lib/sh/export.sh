# shellcheck shell=sh

# Source files and export their assignments.
# Files must contain bare KEY=VALUE lines (no quotes, no shell features)
# to stay portable with systemd's environment.d parser.
# Usage: export_env "$dir"/*.conf
#        export_env "$file1" "$file2"
export_env() {
  if [ $# -eq 0 ]; then
    return 0
  fi
  file=
  return_code=0
  set -a
  for file in "$@"; do
    if [ -f "$file" ]; then
      # shellcheck source=/dev/null
      . "$file" || return_code=$?
    fi
  done
  set +a
  unset file
  return "$return_code"
}

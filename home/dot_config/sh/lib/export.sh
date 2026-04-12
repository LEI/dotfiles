# Source files and export their assignments
# Usage: export_env "$dir"/*.conf
#        export_env "$file1" "$file2"
export_env() {
  if [ $# -eq 0 ]; then
    echo "export_env: missing arguments" >&2
    return 1
  fi
  local _f _rc=0
  set -a
  for _f in "$@"; do
    if [ -f "$_f" ]; then
      # shellcheck source=/dev/null
      . "$_f" || _rc=$?
    fi
  done
  set +a
  return $_rc
}

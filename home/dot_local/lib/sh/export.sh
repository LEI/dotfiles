# shellcheck shell=sh

# Vars below are function-scoped by convention only, POSIX sh has no local

# Source files and export their assignments.
# export_env sources arbitrary shell-syntax confs. The bare KEY=VALUE,
# no-shell-features constraint applies only to confs also consumed by
# systemd EnvironmentFile (e.g. opencode.conf), enforced by a separate test.
# Usage: export_env "$dir"/*.conf
#        export_env "$file1" "$file2"
export_env() {
  if [ $# -eq 0 ]; then
    return 0
  fi
  file=
  rc=
  return_code=0
  set -a
  for file in "$@"; do
    if [ -f "$file" ]; then
      rc=0
      # shellcheck source=/dev/null
      . "$file" || rc=$?
      if [ "$rc" -ne 0 ]; then
        echo "export_env: failed to source $file" >&2
        [ "$return_code" -eq 0 ] && return_code=$rc
      fi
    fi
  done
  set +a
  unset file rc
  return "$return_code"
}

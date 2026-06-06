# shellcheck shell=sh

# Mask the value of NAME=value args whose name ends in a secret keyword
redact_arg() {
  case $1 in
  *TOKEN=?* | *SECRET=?* | *PASSWORD=?* | *PASS=?* | *PRIVATE_KEY=?*)
    printf '%s=[REDACTED]' "${1%%=*}"
    ;;
  *)
    printf '%s' "$1"
    ;;
  esac
}

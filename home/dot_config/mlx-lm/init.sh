# shellcheck shell=bash

mlx-list() {
  mlx_lm manage --scan 2>/dev/null
}

mlx-logs() {
  tail -f "${HOMEBREW_PREFIX:?}/var/log/mlx-lm.log" "$@"
}

hf-list() {
  hf cache ls "$@"
}

hf-usage() {
  hf cache ls --format=json | jq -r '.[] | "\(.repo_type)/\(.repo_id)\t\(.size_on_disk / 1073741824 * 100 | round / 100)G"'
}

hf-cache-rm-all() {
  # shellcheck disable=SC2046
  hf cache rm --yes $(hf-usage | cut -f1)
}

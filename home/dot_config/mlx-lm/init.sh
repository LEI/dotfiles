mlx_list() {
  mlx_lm manage --scan 2>/dev/null
}

mlx_logs() {
  tail -f "${HOMEBREW_PREFIX:?}/var/log/mlx-lm.log" "$@"
}

hf_list() {
  hf cache ls "$@"
}

hf_usage() {
  hf cache ls --format=json | jq -r '.[] | "\(.repo_type)/\(.repo_id)\t\(.size_on_disk / 1073741824 * 100 | round / 100)G"'
}

hf_rm_all() {
  # shellcheck disable=SC2046
  hf cache rm --yes $(hf_usage | cut -f1)
}

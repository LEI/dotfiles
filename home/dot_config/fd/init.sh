# FIXME: config file, environment variable or bin wrapper for non-interactive shells
# https://github.com/sharkdp/fd/issues/362
fd() {
  # local exclude_args=()
  # while IFS= read -r line; do
  #   exclude_args+=(--exclude="$line")
  # done < <(git ls-files --exclude-standard --directory --others)

  command fd \
    --exclude=.git \
    --exclude=node_modules \
    --exclude=vendor \
    --hidden \
    --no-ignore \
    "$@"
}

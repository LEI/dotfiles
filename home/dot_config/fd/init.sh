# FIXME: config file or environment variable for non-interactive shells
# https://github.com/sharkdp/fd/issues/362
fd() {
  command fd --exclude=.git --hidden --no-ignore "$@"
}

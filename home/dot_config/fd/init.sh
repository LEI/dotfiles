# FIXME: config file or environment variable for non-interactive shells
# https://github.com/sharkdp/fd/issues/362
# alias fd="fd --hidden"
fd() {
  command fd --hidden "$@"
}

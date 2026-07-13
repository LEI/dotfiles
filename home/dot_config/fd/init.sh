# shellcheck shell=sh

# fd has no config file, so defaults live in this wrapper (interactive only)
# https://github.com/sharkdp/fd/issues/362
fd() {
  command fd \
    --exclude=.git \
    --exclude=node_modules \
    --exclude=vendor \
    --hidden \
    --no-ignore \
    "$@"
}

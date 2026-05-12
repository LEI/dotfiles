# shellcheck shell=sh

if [ -n "$GOPATH" ] && [ -d "$GOPATH/bin" ]; then
  pathmunge "$GOPATH/bin" replace
fi

# export GOBIN=$HOME/.local/bin
# export GOPATH="$HOME/.config/go"
# export GO111MODULE=on

export GOPATH="${GOTPATH:-$HOME/go}"
# export GOROOT="$HOME/go"
pathmunge "$GOPATH/bin" after

# export GO111MODULE=auto # on

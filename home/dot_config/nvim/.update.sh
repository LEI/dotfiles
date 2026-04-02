#!/bin/sh
set -eu

timeout 5m nvim --headless try \| +LazyUpdate! \| +quitall \| catch \| +cquitall \| end

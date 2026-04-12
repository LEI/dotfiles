#!/bin/sh

set -eux

timeout 5m nvim --headless try \| +LazyUpdate! \| +quitall \| catch \| +cquitall \| end >/dev/null

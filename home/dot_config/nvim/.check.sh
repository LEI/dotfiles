#!/bin/sh

set -eu

nvim --headless try \| +checkhealth \| +quitall \| catch \| +cquitall \| end >/dev/null

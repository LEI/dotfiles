#!/bin/sh
#MISE description="Run nvim checkhealth"

set -eu

nvim --headless try \| +checkhealth \| +quitall \| catch \| +cquitall \| end >/dev/null

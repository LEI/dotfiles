#!/bin/bash

set -euo pipefail

# Required on debian/ubuntu for yq
if [ -x /home/linuxbrew/.linuxbrew/bin/brew ] && ! command -v brew >/dev/null; then
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi

atuin doctor | tail -n+7 | yq --colors --prettyPrint | sed -r '/^\s*$/d'

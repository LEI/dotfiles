#!/bin/bash

set -euo pipefail

# Required on debian/ubuntu if /usr/bin/yq is present
if [ -x /home/linuxbrew/.linuxbrew/bin/brew ]; then
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi

atuin doctor | tail -n+7 | yq --colors --prettyPrint | sed -r '/^\s*$/d'

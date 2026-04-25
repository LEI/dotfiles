#!/bin/bash

set -euo pipefail

# Append brew to PATH for tools like yq that may only be brew-installed.
# Do NOT prepend: the parent task runner already put mise install paths first.
if [ -x /home/linuxbrew/.linuxbrew/bin/brew ] && ! command -v brew >/dev/null; then
  PATH="$PATH:/home/linuxbrew/.linuxbrew/bin:/home/linuxbrew/.linuxbrew/sbin"
fi

mise_doctor() {
  mise doctor --json | yq --colors --prettyPrint '.errors[], .warnings[]'
}

if [ "${CI:-}" = true ]; then
  mise_doctor || echo "WARN: mise doctor exited with code $?" >&2
else
  mise_doctor
fi

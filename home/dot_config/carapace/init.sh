# https://carapace-sh.github.io/carapace-bin/setup.html#bash

if ! command -v carapace >/dev/null; then
  echo "init: command not found: carapace" >&2
  return
fi

if [ -d "$XDG_CONFIG_HOME/carapace/bin" ]; then
  pathmunge "$XDG_CONFIG_HOME/carapace/bin" after
fi

export CARAPACE_BRIDGES='zsh,fish,bash,inshellisense'
export CARAPACE_HIDDEN=1

# shellcheck disable=SC1090 # dynamic completion output
# sed strips '&& +X' to avoid compinit conflict
# . <(carapace _carapace | sed -e 's/ && +X//')
. <(carapace _carapace)

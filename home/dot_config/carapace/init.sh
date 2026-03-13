# https://carapace-sh.github.io/carapace-bin/setup.html#bash
if ! command -v carapace >/dev/null; then
  echo >&2 "Command 'carapace' not found"
  return 0
fi

export CARAPACE_BRIDGES='zsh,fish,bash,inshellisense' # optional

if [ "$shell" = zsh ]; then
  autoload -U +X compinit && compinit # Fixes "zsh: command not found: compdef"
  zstyle ':completion:*' format $'\e[2;37mCompleting %d\e[m'
fi

# shellcheck disable=SC1090 # dynamic completion output
. <(carapace _carapace | sed -e 's/ && +X//')

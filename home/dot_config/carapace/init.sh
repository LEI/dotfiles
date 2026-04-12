# https://carapace-sh.github.io/carapace-bin/setup.html#bash
if ! command -v carapace >/dev/null; then
  # echo >&2 "Command 'carapace' not found"
  return 0
fi

export CARAPACE_BRIDGES='zsh,fish,bash,inshellisense' # optional

if [ "${SHELL##*/}" = zsh ]; then
  autoload -U +X compinit
  # -C skips security check and reuses the completion dump file
  zcompdump="${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zcompdump"
  [ -d "${zcompdump%/*}" ] || mkdir -p "${zcompdump%/*}"
  compinit_flags=(-d "$zcompdump")
  now=$(date +%s)
  mtime=$(stat -f%m "$zcompdump" 2>/dev/null || stat -c%Y "$zcompdump" 2>/dev/null || echo 0)
  # Reuse cached dump if less than a day old
  if [ "$((now - mtime))" -lt 86400 ]; then
    compinit_flags+=(-C)
  fi
  compinit "${compinit_flags[@]}"
  zstyle ':completion:*' format $'\e[2;37mCompleting %d\e[m'
fi

# shellcheck disable=SC1090 # dynamic completion output
. <(carapace _carapace | sed -e 's/ && +X//')

case $- in
*i*) ;;
*) return ;;
esac

# [ -z "$PS1" ] && return

if [[ $- != *i* ]]; then
  # We are being invoked from a non-interactive shell.  If this
  # is an SSH session (as in "ssh host command"), source
  # /etc/profile so we get PATH and other essential variables.
  [[ -n "$SSH_CLIENT" ]] && source /etc/profile

  # Don't do anything else.
  return
fi

# Remove default prompt command
if [ -n "${PROMPT_COMMAND:-}" ] && [[ "$PROMPT_COMMAND" = *"\033]0;"* ]]; then
  # echo >&2 "Original prompt command: $PROMPT_COMMAND"
  export PROMPT_COMMAND=
fi

shell="{{ .shell }}" # ${SHELL##*/}

if [ "$shell" = bash ]; then IS_BASH=true; else IS_BASH=false; fi
# {{- if eq .osID "alpine" }}
BLE_ENABLED="${BLE_ENABLED:-false}"
PREEXEC_ENABLED=${PREEXEC_ENABLED:-$IS_BASH}
# {{- else }}
BLE_ENABLED="${BLE_ENABLED:-$IS_BASH}"
PREEXEC_ENABLED="${PREEXEC_ENABLED:-false}"
# {{- end }}

bench() {
  if [ "${BENCH:-}" = true ]; then
    ORIGINAL_TIMEFORMAT="${TIMEFORMAT:-}"
    if [ -z "${TIMEFORMAT}" ]; then
      TIMEFORMAT="$*: %R"
    fi
    time "$@"
    # unset TIMEFORMAT
    TIMEFORMAT="$ORIGINAL_TIMEFORMAT"
    unset ORIGINAL_TIMEFORMAT
  else
    "$@"
  fi
}

source_files() {
  local dir="$1"
  local ext="${2:-sh}"
  if [ -d "$HOME/.config/$dir" ]; then
    for file in "$HOME/.config/$dir/"*".$ext"; do
      bench source "$file"
    done
  fi
}

source_file_if_exists() {
  local file="$1"
  if [ -f "$file" ]; then
    bench source "$file"
  fi
}

source_plugins() {
  local dir="$1"
  local ext="${2:-sh}"
  if [ -d "$HOME/.config/$dir/plugins" ]; then
    for file in "$HOME/.config/$dir/plugins/"*".$ext"; do
      name="${file##*/}"
      name="${name%".$ext"}"
      # Only source if a command exists with the same name
      if command -v "$name" >/dev/null; then
        bench source "$file"
      fi
    done
  fi
}

# Load environment variables before other scripts
# e.g. INPUTRC before ble.sh
# TODO: .profile
source_file_if_exists "$HOME/.config/sh/environment.sh"

source_files "sh/functions"

if [ -d "$HOME/bin" ]; then
  pathmunge "$HOME/bin" before
fi

if [ -d "$HOME/.local/bin" ]; then
  pathmunge "$HOME/.local/bin" before replace
fi

if [ "$BLE_ENABLED" = true ] && [ -f "$HOME/.local/share/blesh/ble.sh" ]; then
  bench source "$HOME/.local/share/blesh/ble.sh" --rcfile "$HOME/.config/blesh/config.sh" # --noattach
fi
if [ "$PREEXEC_ENABLED" = true ] && [ -f "$HOME/.local/share/bash-preexec.sh" ]; then
  bench source "$HOME/.local/share/bash-preexec.sh"
fi

if [ -d "$HOME/.config/carapace/bin" ]; then
  pathmunge "$HOME/.config/carapace/bin"
fi

# export PATH="/usr/local/opt/ruby/bin:$PATH"

{{- if and (get .features "brew") (ne .os "darwin") }}

if [ -d /home/linuxbrew/.linuxbrew ]; then
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi
{{- end }}

# Must be first to ensure tools are available
if command -v mise >/dev/null; then
  TIMEFORMAT="init mise: %R" bench eval "$(bench mise activate "$shell")"
else
  echo >&2 "Command 'mise' not found"
fi

# if [ -f "${CARGO_HOME:-$HOME/.cargo}/env" ]; then
#   bench source "${CARGO_HOME:-$HOME/.cargo}/env"
# fi
if [ -d "${CARGO_HOME:-$HOME/.cargo}/bin" ]; then
  pathmunge "${CARGO_HOME:-$HOME/.cargo}/bin" after
fi

if [ -d "$GOPATH/bin" ]; then
  pathmunge "$GOPATH/bin" after
fi

if [ -d "$KREW_ROOT/bin" ]; then
  pathmunge "$KREW_ROOT/bin" after
fi

if [ -d "$HOME/.nix-profile/bin" ]; then
  pathmunge "$HOME/.nix-profile/bin" after
fi

if [ -d "$HOME/.node_modules/bin" ]; then
  pathmunge "$HOME/.node_modules/bin" after
fi

if [ -d "$HOME/.local/share/nvim/mason/bin" ]; then
  pathmunge "$HOME/.local/share/nvim/mason/bin" after
fi

# Source plugins after updating PATH and activating mise
source_plugins sh

if command -v direnv >/dev/null; then
  TIMEFORMAT="init direnv: %R" bench eval "$(bench direnv hook "$shell")"
else
  echo >&2 "Command 'direnv' not found"
fi

if command -v starship >/dev/null; then
  TIMEFORMAT="init starship: %R" bench eval "$(bench starship init "$shell")"
else
  echo >&2 "Command 'starship' not found"
fi

if command -v zoxide >/dev/null; then
  TIMEFORMAT="init zoxide: %R" bench eval "$(bench zoxide init "$shell")"
else
  echo >&2 "Command 'zoxide' not found"
fi

# Must be after starship to preserve PROMPT_COMMAND?
# {{- if get .features "atuin" }}
if [ "$shell" != bash ] || [ "$BLE_ENABLED" = true ] || [ "$PREEXEC_ENABLED" = true ]; then
  if command -v atuin >/dev/null; then
    TIMEFORMAT="init atuin: %R" bench eval "$(bench atuin init --disable-up-arrow "$shell")"
  else
    echo >&2 "Command 'atuin' not found"
  fi
fi
# {{- end }}

# {{- if and (get .features "ai") (get .features "git") }}
# if command -v gh >/dev/null; then
#   eval "$(bench gh copilot alias -- "$shell")"
# fi
# {{- end }}

source_file_if_exists "$HOME/.config/sh/aliases.sh"

source_file_if_exists "$HOME/.config/$shell/completion.sh"
source_file_if_exists "$HOME/.config/$shell/environment.sh"
source_file_if_exists "$HOME/.config/$shell/options.sh"

source_file_if_exists "$HOME/.${shell}rc.local"

# https://github.com/akinomyoga/ble.sh#13-set-up-bashrc
if [ "$BLE_ENABLED" = true ] && [ -f "$HOME/.local/share/blesh/ble.sh" ]; then
  [[ ! ${BLE_VERSION-} ]] || ble-attach
fi

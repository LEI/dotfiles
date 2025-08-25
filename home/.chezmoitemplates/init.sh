case $- in
*i*) ;;
*) return ;;
esac
[ -z "$PS1" ] && return

shell="{{ .shell }}" # ${SHELL##*/}

if [ "$shell" = bash ]; then IS_BASH=true; else IS_BASH=false; fi
# {{- if eq .osID "alpine" }}
BLE_ENABLED="${BLE_ENABLED:-false}"
PREEXEC_ENABLED=${PREEXEC_ENABLED:-$IS_BASH}
# {{- else }}
BLE_ENABLED="${BLE_ENABLED:-$IS_BASH}"
PREEXEC_ENABLED="${PREEXEC_ENABLED:-false}"
# {{- end }}

cmd() {
  if [ "$BENCH" = true ]; then
    if [ -z "${TIMEFORMAT}" ]; then
      TIMEFORMAT="$*: %R"
    fi
    time "$@"
    unset TIMEFORMAT
  else
    "$@"
  fi
}

source_files() {
  local dir="$1"
  local ext="${2:-sh}"
  if [ -d "$HOME/.config/$dir" ]; then
    for file in "$HOME/.config/$dir/"*".$ext"; do
      cmd source "$file"
    done
  fi
}

source_file_if_exists() {
  local file="$1"
  if [ -f "$file" ]; then
    cmd source "$file"
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
        cmd source "$file"
      fi
    done
  fi
}

# Load environment variables before other scripts
# e.g. INPUTRC before ble.sh
source_file_if_exists "$HOME/.config/sh/environment.sh"

source_files "sh/functions"

if [ -d "$HOME/bin" ]; then
  pathmunge "$HOME/bin" before
fi

if [ -d "$HOME/.local/bin" ]; then
  pathmunge "$HOME/.local/bin" before replace
fi

# Must be first to ensure tools are available
if command -v mise >/dev/null; then
  TIMEFORMAT="init mise: %R" cmd eval "$(cmd mise activate "$shell")"
else
  echo >&2 "Command 'mise' not found"
fi

if [ -f ~/.cargo/env ]; then
  cmd source ~/.cargo/env
fi

# Source plugins after updating PATH and activating mise
source_plugins sh

if [ "$BLE_ENABLED" = true ] && [ -f "$HOME/.local/share/blesh/ble.sh" ]; then
  cmd source "$HOME/.local/share/blesh/ble.sh" --rcfile "$HOME/.config/blesh/config.sh" # --noattach
fi
if [ "$PREEXEC_ENABLED" = true ] && [ -f "$HOME/.local/share/bash-preexec.sh" ]; then
  cmd source "$HOME/.local/share/bash-preexec.sh"
fi

# {{- if ne .osID "android" }}
# NOTE: "direnv export" causes "SIGSYS bad system call" on termux
if command -v direnv >/dev/null; then
  TIMEFORMAT="init direnv: %R" cmd eval "$(cmd direnv hook "$shell")"
else
  echo >&2 "Command 'direnv' not found"
fi
# {{- end }}

if command -v starship >/dev/null; then
  TIMEFORMAT="init starship: %R" cmd eval "$(cmd starship init "$shell")"
else
  echo >&2 "Command 'starship' not found"
fi

if command -v zoxide >/dev/null; then
  TIMEFORMAT="init zoxide: %R" cmd eval "$(cmd zoxide init "$shell")"
else
  echo >&2 "Command 'zoxide' not found"
fi

# Must be after starship to preserve PROMPT_COMMAND?
# {{- if .features.atuin }}
if [ "$shell" != bash ] || [ "$BLE_ENABLED" = true ] || [ "$PREEXEC_ENABLED" = true ]; then
  if command -v atuin >/dev/null; then
    TIMEFORMAT="init atuin: %R" cmd eval "$(cmd atuin init --disable-up-arrow "$shell")"
  else
    echo >&2 "Command 'atuin' not found"
  fi
fi
# {{- end }}

# {{- if and .features.ai .features.git }}
# if command -v gh >/dev/null; then
#   eval "$(cmd gh copilot alias -- "$shell")"
# fi
# {{- end }}

source_file_if_exists "$HOME/.config/sh/aliases.sh"

# Source shell specifc files
# source_files "$shell"
source_file_if_exists "$HOME/.config/$shell/competion.sh"
source_file_if_exists "$HOME/.config/$shell/environment.sh"
source_file_if_exists "$HOME/.config/$shell/options.sh"

source_file_if_exists "$HOME/.${shell}rc.local"

# https://github.com/akinomyoga/ble.sh#13-set-up-bashrc
if [ "$BLE_ENABLED" = true ] && [ -f "$HOME/.local/share/blesh/ble.sh" ]; then
  [[ ! ${BLE_VERSION-} ]] || ble-attach
fi

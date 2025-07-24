# [[ $- == *i* ]] || return

shell="{{ .shell }}" # ${SHELL##*/}

IS_BASH="$([ "$shell" = bash ] && echo true || echo false)"
BLE_ENABLED="${BLE_ENABLED:-$IS_BASH}"
PREEXEC_ENABLED="${PREEXEC_ENABLED:-false}"

source_files() {
  local dir="$1"
  local ext="${2:-sh}"
  if [ -d "$HOME/.config/$dir" ]; then
    for file in "$HOME/.config/$dir/"*".$ext"; do
      # shellcheck disable=SC1090
      source "$file"
    done
  fi
}

source_if_exists() {
  local file="$1"
  if [ -f "$file" ]; then
    # shellcheck disable=SC1090
    source "$file"
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
        # shellcheck disable=SC1090
        source "$file"
      fi
    done
  fi
}

main() {
  local file name

  # Source common functions (pathmunge)
  source_files "sh/functions"

  # if [ -d "$HOME/bin ]; then
  #   pathmunge "$HOME/bin before
  # fi

  if [ -d "$HOME/.local/bin" ]; then
    pathmunge "$HOME/.local/bin" before replace
  fi

  # Must be first to ensure tools are available
  if command -v mise >/dev/null; then
    eval "$(mise activate "$shell")"
  else
    echo >&2 "Command 'mise' not found"
  fi

  if [ -f ~/.cargo/env ]; then
    # shellcheck disable=SC1090
    source ~/.cargo/env
  fi

  # Source plugins after updating PATH and activating mise
  source_plugins sh

  # {{- if ne .osid "android" }}
  # NOTE: "direnv export" causes "SIGSYS bad system call" on termux
  if command -v direnv >/dev/null; then
    eval "$(direnv hook "$shell")"
  else
    echo >&2 "Command 'direnv' not found"
  fi
  # {{- end }}

  if command -v starship >/dev/null; then
    eval "$(starship init "$shell")"
  else
    echo >&2 "Command 'starship' not found"
  fi

  if command -v zoxide >/dev/null; then
    eval "$(zoxide init "$shell")"
  else
    echo >&2 "Command 'zoxide' not found"
  fi

  if [ "$BLE_ENABLED" = true ] && [ -f "$HOME/.local/share/blesh/ble.sh" ]; then
    # shellcheck disable=SC1091
    source "$HOME/.local/share/blesh/ble.sh" --rcfile "$HOME/.config/blesh/config.sh" # --noattach
  fi
  if [ "$PREEXEC_ENABLED" = true ] && [ -f "$HOME/.local/share/bash-preexec.sh" ]; then
    # shellcheck disable=SC1091
    source "$HOME/.local/share/bash-preexec.sh"
  fi
  # Must be after starship to preserve PROMPT_COMMAND?
  if [ "$shell" != bash ] || [ "$BLE_ENABLED" = true ] || [ "$PREEXEC_ENABLED" = true ]; then
    if command -v atuin >/dev/null; then
      eval "$(atuin init --disable-up-arrow "$shell")"
    else
      echo >&2 "Command 'atuin' not found"
    fi
  fi

  source_if_exists "$HOME/.config/sh/environment.sh"
  source_if_exists "$HOME/.config/sh/aliases.sh"

  # Source shell specifc files
  source_files "$shell"

  source_if_exists "$HOME/.${shell}rc.local"

  # https://github.com/akinomyoga/ble.sh#13-set-up-bashrc
  if [ "$BLE_ENABLED" = true ] && [ -f "$HOME/.local/share/blesh/ble.sh" ]; then
    [[ ! ${BLE_VERSION-} ]] || ble-attach
  fi
}

main "$@"
unset main

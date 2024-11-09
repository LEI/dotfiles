shell="{{ .shell }}"

main() {
  local file name

  # Source shell specifc files
  if [ -d "$HOME/.config/$shell" ]; then
    for file in "$HOME/.config/$shell/"*.sh; do
      # shellcheck disable=SC1090
      source "$file"
    done
  fi

  # Source functions and plugins
  if [ -d "$HOME/.config/sh" ]; then
    for file in "$HOME/.config/sh/functions"/*.sh; do
      # shellcheck disable=SC1090
      source "$file"
    done
    # Only source plugins if a command exists with the same name
    for file in "$HOME/.config/sh/plugins"/*.sh; do
      name="${file##*/}"
      name="${name%.sh}"
      if command -v "$name" >/dev/null; then
        # shellcheck disable=SC1090
        source "$file"
      fi
    done
  fi

  # if [ -d "$HOME/bin ]; then
  #   pathmunge "$HOME/bin after
  # fi

  if [ -d "$HOME/.local/bin" ]; then
    pathmunge "$HOME/.local/bin" after
  fi

  # Must be first to ensure tools are available
  if command -v mise >/dev/null; then
    eval "$(mise activate "$shell")"
  else
    echo >&2 "Command 'mise' not found"
  fi

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

  if [ -f ~/.local/share/blesh/ble.sh ]; then
    # shellcheck disable=SC1090
    source ~/.local/share/blesh/ble.sh
  fi
  # Must be after starship to preserve PROMPT_COMMAND?
  if command -v atuin >/dev/null; then
    eval "$(atuin init --disable-up-arrow "$shell")"
  else
    echo >&2 "Command 'atuin' not found"
  fi

  # Source aliases
  if [ -f "$HOME/.config/sh/aliases.sh" ]; then
    # shellcheck disable=SC1091
    source "$HOME/.config/sh/aliases.sh"
  fi

  if [ -f "$HOME/.${shell}rc.local" ]; then
    # shellcheck disable=SC1090
    source "$HOME/.${shell}rc.local"
  fi
}

main "$@"
unset main

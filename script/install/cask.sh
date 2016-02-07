#!/usr/bin/env bash

# cask.sh

install_cask() {
  local cask_path="$DOT_ROOT/init/cask."
  local name
  # open /Applications/$app.app

  if confirm "Brew cask init" "${cask_path}*.sh" Y; then
    for cask in ${cask_path}*.sh; do
      [[ ! -f "$cask" ]] && return 1

      # Capitalize cask name
      name=${cask##*/} # Remove path
      # name=${name%.*} # Remove extension
      name="$(echo "${name:0:1}" | tr "[:lower:]" "[:upper:]")${name:1}"

      # Use cask apps cli to setup defaults
      log_info "$name" "$cask"
      if source "$cask"; then
        log_success "$name"
      else
        log_error "An error occurred"
      fi
    done
  fi
}

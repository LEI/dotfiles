#!/usr/bin/env bash

# install.sh

install_packages() {
  case $UNAME in
    Darwin)
        #install_cask && \
      install_homebrew_bundle && \
        install_cask_files
      ;;
    *)
      log_warn "No packages for $UNAME" ":("
      ;;
  esac
}

install_homebrew_bundle() {
  local brew=$(which brew) # /usr/local/bin/brew

  if [[ ! -n "$brew" ]] || [[ ! -x "$brew" ]]; then
    log_info "Homebrew" "Installing"

    # Install the correct homebrew for each OS type
    case $UNAME in
      Darwin)
        ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
        ;;
      Linux)
        ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/linuxbrew/go/install)"
        ;;
      *)
        log_warn "Unknown platform $UNAME"
        ;;
    esac

    log_success "Homebrew" "Installed"
  fi

  if [[ -x "$brew" ]]; then
    if confirm "Homebrew bundle" "" N; then
      # Check exit statuses?

      # Make sure we're using the latest Homebrew
      log "> brew update" "Updating"
      brew update

      # Upgrade any already installed formulae
      log "> brew upgrade" "Upgrading"
      brew upgrade

      # brew tap Homebrew/bundle
      local brewfile="$DOT_INIT/darwin/Brewfile"
      if [[ -f "$brewfile" ]]; then
        log "> brew bundle" "Brewfile: $brewfile"
        #brew bundle
        #TODO: DOT_CONFIG_BREW&CASK?
        # https://github.com/Homebrew/homebrew-bundle
        # https://github.com/caskroom/homebrew-cask
        #"$DOT_ROOT/os/darwin/brewfile" #caskfile?
        brew bundle --file="$brewfile"
      else
        log_error "Brewfile not found" "$brewfile"
      fi

      # # Remove outdate version from the cellar
      log "> brew cleanup" "Cleaning"
      brew cleanup

      log "> brew doctor" "Verifying"
      brew doctor

      log_success "Homebrew"
    fi
  else
    log_error "Could not execute $brew"
    return 1
  fi
}

# Configure cask apps settings
install_cask_files() {
  local cask_path="$DOT_INIT/darwin/cask"
  local name=
  # open /Applications/$app.app

  if confirm "Homebrew cask settings" "${cask_path}/*" Y; then
    for cask in ${cask_path}/*; do
      [[ ! -f "$cask" ]] && return 1

      # Capitalize cask name
      name=${cask##*/} # Remove path
      # name=${name%.*} # Remove extension
      name="$(echo "${name:0:1}" | tr "[:lower:]" "[:upper:]")${name:1}"

      log_info "$name" "$cask"
      if source "$cask"; then
        log_success "$name"
      else
        log_error "An error occurred"
      fi
    done
  fi
}

uninstall_packages() {
  log_error "Not implemented" "uninstall_packages()"
}

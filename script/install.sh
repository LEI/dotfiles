#!/usr/bin/env bash

# install.sh

install() {
	homebrew
}

homebrew() {
    local brew=$(which brew) # /usr/local/bin/brew

    if [[ ! -n "$brew" ]] || [[ ! -x "$brew" ]]; then
        log_info "Homebrew" "Installing"

        # Install the correct homebrew for each OS type
        case $UNAME in
            darwin)
                ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
                ;;
            linux)
                ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/linuxbrew/go/install)"
                ;;
            *)
                die "Unknown platform: $UNAME"
                ;;
        esac
    fi

    if [[ -x "$brew" ]]; then
        log_success "Homebrew" "Installed"

        # Make sure we're using the latest Homebrew
        log_exec "brew update" "..."
        # brew update

        # Upgrade any already installed formulae
        log_exec "brew upgrade" "..."
        # brew upgrade

        # brew tap Homebrew/bundle
        log_exec "brew bundle" "..."
        # brew bundle check

        # # Remove outdate version from the cellar
        log_exec "brew cleanup" "..."
        # brew cleanup

        # brew doctor
    fi
}

install

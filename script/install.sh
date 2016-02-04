#!/usr/bin/env bash

# install.sh

import "log"
import "prompt"

install() {
	install_homebrew

	install_cask
}

install_homebrew() {
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

		log_success "Homebrew" "Installed"
    fi

    if [[ -x "$brew" ]] && confirm "Brew bundle" "$DOT_ROOT/Brewfile" N; then

        # Make sure we're using the latest Homebrew
        log_exec "brew update" "Updating"
        brew update

        # Upgrade any already installed formulae
        log_exec "brew upgrade" "Upgrading"
        brew upgrade

        # brew tap Homebrew/bundle
        log_exec "brew bundle" "Bundling"
        #brew bundle
		#TODO: DOT_CONFIG_BREW
		# https://github.com/Homebrew/homebrew-bundle
		# https://github.com/caskroom/homebrew-cask

        # # Remove outdate version from the cellar
        log_exec "brew cleanup" "Cleaning"
        brew cleanup

        brew doctor

		log_success "Brewfile"
    fi
}

install_cask() {
	local cask_root="$DOT_ROOT/cask"

	# local app="$(${cask:0:1} | tr "[:lower:]" "[:upper:]")${cask:1}"
	# open /Applications/$app.app

	for cask in $cask_root/*; do
		if source "$cask"; then
			log_success "$cask"
		else
			log_error "$cask"
		fi
	done
}

install

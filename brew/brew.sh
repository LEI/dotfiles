#!/bin/bash
#
# Homebrew utils
# Uses utils, print, ask

install_homebrew () {
	# If OS X and brew not already installed
	if [[ "$OSTYPE" =~ ^darwin ]] && [[ ! "$(type -P brew)" ]]; then

		if ask "Download Homebrew ?" Y; then

			#Skip the "Press enter to continue…" prompt.
			true | ruby -e "$(curl -fsSL https://raw.github.com/mxcl/homebrew/go)"
			info "Homebrew installed"
		fi

	else
		success "Homebrew already here" " " true
	fi
}

brew_bundle () {
	local opts="--appdir=/Applications"

	if [ -n $HOMEBREW_CASK_OPTS ]; then
		opts=$HOMEBREW_CASK_OPTS
	fi

	local file=$1/.${1}

	info "brew bundle $file" "..."

	[ -f "$file" ] || warn "$file does not exists"

	# & ?
	if [ -f "$file" ] && silent brew bundle "$file" "$opts"; then
		success "$1 successfully bundled !"
		return 0
	else
		fail "$1 failed to bundle !"
		return 1
	fi
}

do_cask () {
	local cask=$1
	((indent_level++))
		if silent brew cask install $cask; then
			((indent_level++))
			local file=$DOTFILES_DIR/cask/$cask
			local app="$(tr '[:lower:]' '[:upper:]' <<< ${cask:0:1})${cask:1}"
			if silent source_file $file; then
				success "$app" " "
				open /Applications/$app.app
				((indent_level--))
			else
				fail "$app" " "
				((indent_level--))
			fi
		fi
	((indent_level--))
}

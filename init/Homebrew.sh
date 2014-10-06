#!/bin/sh
#
# Bundle homebrew
# https://github.com/tacahilo/.dotfiles/blob/master/install_homebrew.sh

TAPS=(
	homebrew/versions
	caskroom/versions
)

FORMULAS=(
	# Install GNU core utilities (those that come with OS X are outdated)
	# Don’t forget to add `$(brew --prefix coreutils)/libexec/gnubin` to `$PATH`.
	coreutils
	# Install some other useful utilities like `sponge`
	moreutils
	# Install GNU `find`, `locate`, `updatedb`, and `xargs`, `g`-prefixed
	findutils
	# Install GNU `sed`, overwriting the built-in `sed`
	"gnu-sed --default-names"
	# Install Bash 4
	# Note: don’t forget to add `/usr/local/bin/bash` to `/etc/shells` before running `chsh`.
	bash
	bash-completion
	# Install wget with IRI support
	"wget --enable-iri"
	# Install RingoJS and Narwhal
	# Note that the order in which these are installed is important; see http://git.io/brew-narwhal-ringo.
	ringojs
	narwhal
	# Install more recent versions of some OS X tools
	"vim --override-system-vi"
	homebrew/dupes/grep
	homebrew/dupes/screen
	"homebrew/php/php55 --with-gmp"
	# Install other useful binaries
	ack
	bfg
	exiv2
	foremost
	git
	git-flow
	hashpump
	"imagemagick --with-webp"
	lynx
	nmap
	#node # This installs `npm` too using the recommended installation method
	p7zip
	pigz
	pv
	rename
	rhino
	sqlmap
	tree
	ucspi-tcp # `tcpserver` et al.
	webkit2png
	xpdf
	zopfli
	lua
	glib
	rsstail
	irssi
	# Install Caskroom
	caskroom/cask/brew-cask
)

CASKS=(
	google-chrome
	#google-chrome-canary
	firefox
	#firefox-aurora
	opera
	#opera-developer
	#opera-next
	torbrowser
	#atom
	#sublime-text3
	#phpstorm
	mou
	#tower
	#sourcetree
	#gitx-l
	vagrant
	#vagrant-manager
	virtualbox
	#vmware-fusion
	#filezilla
	transmit
	ampps
	sequel-pro
	robomongo
	kaleidoscope
	reggy
	alfred
	#atext
	#bartender
	caffeine
	flux
	hyperdock
	imagealpha
	imageoptim
	#miro-video-converter
	onyx
	the-unarchiver
	vlc
	cakebrew
	dropbox
	evernote
	#lastpass-universal
	little-snitch
	skype
	transmission
	qlcolorcode
	qlstephen
	qlmarkdown
	qlprettypatch
	quicklook-json
	quicklook-csv
	betterzipql
	webp-quicklook
)

function setup() {
	# https://raw.github.com/mxcl/homebrew/go
	[ -x "/usr/local/bin/brew" ] || {
		ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
	}
}

function install_brewfiles() {
	for tap in "${TAPS[@]}"; do
		brew tap $tap
	done

	for formula in "${FORMULAS[@]}"; do
		brew install $formula
	done
}

function install_caskfiles() {
	for cask in "${CASKS[@]}"; do
		brew cask install --appdir=/Applications $cask
	done

	# Link apps to Alfred
	brew cask alfred link

	brew cask cleanup
}

function main() {
	setup

	# Make sure we’re using the latest Homebrew
	brew update
	# Upgrade any already-installed formulae
	brew upgrade

	install_brewfiles
	install_caskfiles

	# Remove outdated versions from the cellar
	brew cleanup
	#brew doctor
}

main

#!/bin/bash
# bootstrap.sh

# .		Import
# >		Run
# ~		Source

set -o nounset
set -o errexit

bootstrap() {
	unset -f bootstrap

	# Extend matching operators
	shopt -s extglob

	BOOTSTRAP_ROOT="${DOTFILES_ROOT}/dot"
	TARGET=$HOME

	DRY_RUN=false
	DEBUG=false

	# Import by alphabetical order
	load "${BOOTSTRAP_ROOT}/*/*.sh"
	load "${BOOTSTRAP_ROOT}/!(bootstrap).sh"

	info "Using $DOTFILES_ROOT"

	# Boot
	parse_args "$@" || return 1

	debug "TARGET => $TARGET"

	dot || return 1
}

# Source files
load() {
	for file in $@; do
		# echo "source $file"
		if [ -f "$file" ]; then
			source "$file" || return 1
		fi
	done
	unset file
}

# Entry point
bootstrap "$@"

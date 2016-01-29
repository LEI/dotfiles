#!/bin/bash
# bootstrap.sh

# .		Import
# >		Exec
# ~		Source

set -o nounset
set -o errexit

bootstrap() {
	unset -f bootstrap

	# Extend matching operators
	shopt -s dotglob
	# shopt -s nullglob

	BOOTSTRAP_ROOT="${DOT_ROOT}/dot"
	DOT_IGNORE_FILE="${DOT_ROOT}/.dotignore"
	DOT_TARGET=$HOME

	DRY_RUN=false
	DEBUG=false

	# Import scripts by alphabetical order
	load "${BOOTSTRAP_ROOT}/*/*.sh"
	load "${BOOTSTRAP_ROOT}/!(bootstrap).sh"

	# .dotignore
	DOT_IGNORE=$(read_file "${DOT_IGNORE_FILE}")

	info "Using $DOT_ROOT"

	# Get options
	parse_args "$@"

	# Do symlinks
	link_files "$DOT_ROOT" "$DOT_TARGET" "$DOT_IGNORE"
}

# Source files
load() {
	local file
	for file in $@; do
		# echo "source $file"
		if [[ -f "$file" ]]; then
			source "$file" || return 1
		fi
	done
}

not_root() {
	if [[ $USER == "root" ]]; then
		echo "Root detected, aborting."
		exit 1
	else



	fi
}

# Boot
not_root
bootstrap "$@"

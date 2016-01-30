#!/bin/bash
# bootstrap.sh

# .		Import
# >		Command
# ~		Link

set -o nounset
set -o errexit

bootstrap() {
	unset -f bootstrap

	# Extend matching operators
	shopt -s dotglob
	# shopt -s nullglob

	# Paths
	UNAME=$(uname -s) # Darwin|Linux
	DOT_TARGET=$HOME
	BOOTSTRAP_ROOT="${DOT_ROOT}/dot"
	DOT_IGNORE_FILE="${DOT_ROOT}/.dotignore"

	# Options
	DEPTH=0 # starting directory
	MAX_DEPTH=1 # symlink folders at the level
	DRY_RUN=false
	DEBUG=false
	TIMESTAMPS=false

	# Display
	indent_unit="  "
	indent_level=0

	# Import scripts by alphabetical order
	load "${BOOTSTRAP_ROOT}/*/*.sh"
	load "${BOOTSTRAP_ROOT}/!(bootstrap).sh"

	# .dotignore
	DOT_IGNORE=$(read_file "${DOT_IGNORE_FILE}")

	# Get options
	parse_args "$@"

	debug "Using" "$DOT_ROOT"
	info "Targeting" "$DOT_TARGET/"
	log "Ignoring" "$DOT_IGNORE"

	# Create symbolic lins
	symlink_files "$DOT_ROOT" "$DOT_TARGET" "$DOT_IGNORE" $DEPTH $MAX_DEPTH && \
		success "Symlinks done" || (error "Something went wrong" && return 1)

	# return
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

no_root() {
	if [[ $USER == "root" ]]; then
		echo "Root detected, aborting."
		exit 1
	fi
}

# Boot
no_root
bootstrap "$@"

#!/bin/bash
# bootstrap.sh

# .		Import
# >		Command
# ~		Link

set -o nounset
set -o errexit

# Extend matching operators
shopt -s dotglob
# shopt -s nullglob

bootstrap() {
	unset -f bootstrap

	# Paths
	UNAME=$(uname -s) # Darwin|Linux
	DOT_TARGET=$HOME
	DOT_BOOTSTRAP="$DOT_ROOT/dot"
	DOT_IGNORE_FILE="$DOT_ROOT/.dotignore"

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
	load "$DOT_BOOTSTRAP/*/*.sh"
	load "$DOT_BOOTSTRAP/!(bootstrap).sh"

	# .dotignore
	DOT_IGNORE=$(read_file "$DOT_IGNORE_FILE")

	# Get options
	parse_args "$@"
	# TODO: DOT_TARGET // -> slashes cleanup

	# READY #

	# Header info
	debug "$UNAME" "System"
	debug "Debug mode" "Enabled"
	[ "$DRY_RUN" = true ] && local msg="DRY RUN: "
	log "${msg-}$DOT_ROOT -> $DOT_TARGET"
	info "${DOT_IGNORE_FILE#$DOT_ROOT/}" "$DOT_IGNORE"

	# Create symbolic lins
	symlink_files "$DOT_ROOT" "$DOT_TARGET" "$DOT_IGNORE" $DEPTH $MAX_DEPTH && \
		success "Symlinked $DOT_TARGET" "$DOT_ROOT" || (error "Something went wrong" && return 1)

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

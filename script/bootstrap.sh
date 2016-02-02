#!/usr/bin/env bash

# bootstrap.sh

import "lib/config"

bootstrap() {

	# # Extend matching operators
	# shopt -s extglob
	# # Loop on dotfiles
	# shopt -s dotglob
	# # Do not loop on empty directory
	# shopt -s nullglob
	# # Recursive globbing
	# shopt -s globstar

	# Configuration
	TIMESTAMPS=${TIMESTAMPS-false}
	DRY_RUN=${DRY_RUN-false}
	DEBUG=${DEBUG-false}
	# MIN_DEPTH=1
	# MAX_DEPTH=1

	# import "lib/git"

	# User settings
	config "$DOT_RC"

	log_debug "Debug mode" "Enabled"

	log_debug "Hello" "$DOT_AUTHOR_NAME"
	log_debug "FILES =>" "${DOT_FILES[*]}"
	log_debug "IGNORE =>" "${DOT_IGNORE[*]}"

	# log_info "Configuration loaded:" "${CONFIG[@]}"

	# Templates
	# for template in $DOT_FILES/**/template.*; do
	# 	process_template_file "$template"
	# done

	# Symlinks

}

# read_file() {
# 	local file="$1"
# 	while read -r line; do
# 		[[ -z "$line" ]] && continue # Empty
# 		[[ ${line:0:1} == "#" ]] && continue # Comment
# 		echo "$line"
#
# 	done < "$file"
# }

# process_template_file() {
# 	local file="$1"
# 	log_warn "TODO" "Process template ${file/$DOT_FILES\/}"
# }

# load() {
# 	local file=$1
# 	if [[ -f "$1" ]]; then
# 		if source $1; then
# 			success "Loaded" "$1"
# 		else
# 			die "Could not load '$file'"
# 		fi
# 	else
# 		error "Not a file" "$1"
# 	fi
# }

# check_env() {
# 	local min_bash_version=4
# 	local bash_version=${BASH_VERSION%%[^0-9]*}
# 	if [[ $bash_version -lt $min_bash_version ]]; then
# 		printf "%s\r\n" "This script requires bash > ${min_bash_version}."
# 		exit 1
# 	fi
# }


# [[ "$0" == "$BASH_SOURCE" ]] && main "$@"

bootstrap

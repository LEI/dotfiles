#!/usr/bin/env bash

# bootstrap.sh


bootstrap() {
	log_debug "FILES =>" "${DOT_FILES[*]}"
	# log_debug "IGNORE =>" "${DOT_IGNORE[*]}"

	templates
	symlinks
}

templates() {
	# Templates
	for template in $DOT_ROOT/**/*.template; do # Cannot glob on bash 3
		log_warn "TODO" "Process template ${template/$DOT_ROOT\/}"
	done
}

symlinks() {

	# Symlinks
	for link in ${DOT_FILES[@]}; do
		if [[ "$link" =~ [*:*] ]]; then
			local src=${link%:*}
			local dst=${link#*:}
			[[ -z "$dst" ]] && dst=$src
			for path in ${src[@]}; do
				log_info "$path ->" "~/.${path#*/}"
			done
		else
			local src="$link"
			local dst="$link"
			log_info "$src ->" "~/$dst"
		fi
	done

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

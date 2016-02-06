#!/usr/bin/env bash

# bootstrap.sh

import "lib/prompt"
import "lib/file"

bootstrap() {
	log_debug "FILES =>" "${DOT_FILES[*]}"
	# log_debug "IGNORE =>" "${DOT_IGNORE[*]}"

	template_files
	symlink_files
}

template_files() {
	local file
	# Gather variable names for sed
	local vars=("${!DOT_USER_*}")
	# Look for each file ending with '.template' except .dotrc
	local templates=$(find $DOT_ROOT -name *.template ! -path $DOT_RC_TEMPLATE)

	for template in ${templates[@]}; do
		# Extract actual path
		file=${template%.template}

		# Confirm processing if target file exists
		if [[ -f "$file" ]]; then
			confirm "Overwrite ${file/$DOT_ROOT\//}" "$template" Y || continue
		fi

		# Fill file
		sed_file "$file" "$template" "${vars[@]}" || die "Could not sed file"
		log_success "Template processed" "${file/$DOT_ROOT\/}"
	done
}

symlink_files() {
	local src dst
	local prefix="."
	local dot_files
	# echo "-> ${DOT_FILES[@]}"

	# Parse symlink expressions
	for expr in ${DOT_FILES[@]}; do

		if [[ "$expr" =~ [*:*] ]]; then
			# Path specified
			src=${expr%:*}
			dst=${expr#*:}
			[[ -z "$dst" ]] && dst=$src
			# 	for path in ${src[@]}; do
			# 		log_info "$path ->" "~/.${path#*/}"
			# 	done
		else
			# Link to home and add prefix
			src="$expr"
			dst="${prefix}${expr#*/}"
		fi

		src="$DOT_ROOT/$src"
		dst="$DOT_TARGET/$dst"
		for file in $(find_files "$src"); do
			# [[ -e "$file" ]] || log_warn "No such file or directory" "$file"
			stat=$(stats_file "$file" "$dst")
			echo "stat -> $stat"
			case $stat in
				broken) log_success "$file" ;;
				link) log_warn "$file" ;;
				file|directory) log_error "$file" ;;
				empty*) log_info "$file is $stat!" ;;
				*) log_error "$file is $stat" ;;
				# 0) log_success "symlink_file $file $dst/" ;;
				# 10) log_error "$file" ;;
				# 11) log_warn "$file" ;;
				# 12) confim "$file" ;;
				# *) log_debug "Unknown status: $?" ;;
			esac
		done


	done
	die "${dot_files[@]}"

}

find_files() {
	local path=$1

	find $path -prune ! -name *.template -print # \
		#2> >(grep -i -v "no such file or directory" >&2 || log_error "No such file or directory")
	# -ok {} \;

	# local cmd=""
	# printf "%s" "$cmd"
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

bootstrap

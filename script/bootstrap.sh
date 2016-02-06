#!/usr/bin/env bash

# bootstrap.sh

bootstrap() {
	log_debug "FILES =>" "${DOT_FILES[*]}"
	# log_debug "IGNORE =>" "${DOT_IGNORE[*]}"

	template_files
	symlink_files
}

template_files() {
	# Templates
	for template in $DOT_ROOT/*/*.template; do # Cannot glob on bash 3
		log_warn "TODO" "Process template ${template/$DOT_ROOT\/}"
	done
}

symlink_files() {
	local src dst target
	local prefix="."
	# echo "-> ${DOT_FILES[@]}"
	# Symlinks
	for link in ${DOT_FILES[@]}; do

		if [[ "$link" =~ [*:*] ]]; then
			# Path specified
			src=${link%:*}
			dst=${link#*:}
			[[ -z "$dst" ]] && dst=$src
			# 	for path in ${src[@]}; do
			# 		log_info "$path ->" "~/.${path#*/}"
			# 	done
		else
			# Link to home and add prefix
			src="$link"
			dst="${prefix}${link#*/}"
		fi

		dst="$DOT_TARGET/$dst"

		log_debug "$src ->" "$dst"

		target="$src" #"$DOT_TARGET/$dst"
		find_files "$target" || log_error "$target" "No such file or directory"

	done

}

find_files() {
	local path=$1

	# -ok {} \;
	find $path -prune ! -name *.template -print \
		2> >(grep -i -v "no such file or directory" >&2)

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

#!/bin/bash
# file.sh

# Parse a file
read_file() {
	local file=$1
	local content=

	while read line; do
		# Skip empty lines
		[[ -z "${line}" ]] && continue
		# Skip comments
		[[ ${line:0:1} == "#" ]] && continue

		content+=("$line")
	done < "${file}"

	echo "${content[@]}"
}

link_files() {
	local source=$1
	local target=$2
	local ignore=$3
	local link_dir=${4-false}
	local file

	for file in $source/*; do
		# Exclude .dotignore files
		in_array ${file#$source/} ignore && \
			# debug "${file#$source/} is ignored" && \
			continue

		if [[ "$link_dir" != true ]] && [[ -d "$file" ]]; then
			# debug "${file#$source/} is a directory, symlinking $file/*"
			link_files "$file" "$target/${file#$source/}" "$ignore" true # Recursive symlink
		elif [[ -f "$file" ]] || ([[ -d "$file" ]] && [[ "$link_dir" = true ]]); then
			# debug "Symlinking $file -> $target/${file#$source/}"
			symlink "$file" "$target/${file#$source/}"
		else
			error "${file#$source/} is weird"
		fi
	done
}

symlink() {
	local source=$1
	local target=$2
	local target_link skip remove

	#TODO: ~

	if [[ -h "$target" ]] && [[ ! -e "$target" ]]; then
		# Broken link
		error "$target broken link"
		remove=true
	elif [[ -h "$target" ]]; then
		# Symbolic link (-o -L?)
		target_link=$(readlink $target)
		if [[ "$target_link" == "$source" ]]; then
			success "$target already linked"
			skip=true
		else
			warn "$target already linked to $target_link"
			if confirm "Remove $target_link current symlink? (y/n)"; then
				remove=true
			else
				skip=true
			fi
		fi
	elif [[ -f "$target" ]]; then
		# File
		if confirm "Remove $target actual file? (y/n)"; then
			remove=true
		else
			skip=true
		fi
	elif [[ -d "$target" ]]; then
		# Directory
		# info "$target is a dir.."
		if confirm "Remove $target actual directory? (y/n)"; then
			remove=true
		else
			skip=true
		fi
	fi

	# Check if the file has to be removed
	if [[ "$remove" = true ]]; then
		if [ "$DRY_RUN" != true ]; then
			info ">>> rm $target"
		fi
	fi

	# Check if the symbolic link can be created
	if [[ "$skip" != true ]]; then

		if [ "$DRY_RUN" != true ]; then
			info ">>> ln -s $source $target"
		fi

		success "$source linked to $target"
	fi

}

#!/bin/bash
# symlink.sh

# . lib/array.sh
# . utils/logger.sh
# . utils/prompt.sh

symlink_files() {
	local source=$1
	local target=$2
	local ignore=$3
	local depth=$4
	local max_depth=$5
	local file

	# Formatted paths
	local src=$(pretty_path $source)
	local dst=$(pretty_path $target)

	# Should not happen
	[[ $depth -gt $max_depth ]] && {
		warn "Reached depth $depth"
		return 1
	}

	debug "Going deep:" "$depth"

	# Prompt the user
	confirm "Symlink files" "$src/* to $dst/" Y || {
		warn "Aborting"
		return
	}

	for file in $source/*; do

		# echo "current depth: $depth"
		((indent_level+=1))

		# Exclude .dotignore files
		if in_array ${file#$source/} ignore; then
			debug "Ignored" "${file#$source/}"

			((indent_level-=1))
			continue
		fi

		if [[ -f "$file" ]]; then
			# File found, trying to link
			do_symlink "$file" "$target/${file#$source/}"
		elif [[ $depth -eq $max_depth ]] && [[ -d "$file" ]]; then
			# Reached max depth, symlink directories
			((depth-=1))
			do_symlink "$file" "$target/${file#$source/}"
			# continue
		elif [[ $depth -lt $max_depth ]] && [[ -d "$file" ]]; then
			# Going deep into directory, self call
			((depth+=1))
			# debug "INCREMENTING DEPTH, NOW:" "$depth"
			symlink_files "$file" "$target/${file#$source/}" "$ignore" $depth $max_depth && {
					((indent_level-=1))
					continue
			}
		else
			error "Weird file" "${file#$source/}" # && return 1
		fi

		((indent_level-=1))

	done

	return
}

do_symlink() {
	local source=$1
	local target=$2
	# local backup=false
	local remove=false
	local skip=false # Do not skip by default

	# Formatted paths
	local src=$(pretty_path $source)
	local dst=$(pretty_path $target)

	# TODO: .bak check

	if [[ -h "$target" ]] && [[ ! -e "$target" ]]; then
		# Broken link
		error "Broken link" "$dst"
		if confirm "Remove it" "$dst" Y; then
			remove=true
		else
			skip=true
		fi
	elif [[ -h "$target" ]]; then
		# Symbolic link (-o -L?)
		local target_link=$(readlink $target)
		if [[ "$target_link" == "$source" ]]; then
			success "Already linked" "$dst"
			skip=true
		else
			warn "$dst already linked" "$target_link"
			if confirm "Remove symlink" "$target_link" N; then
				remove=true
			else
				skip=true
			fi
		fi
	elif [[ -f "$target" ]]; then
		# File
		if confirm "Replace existing file" "$dst" Y; then
			remove=true
		else
			skip=true
		fi
	elif [[ -d "$target" ]]; then
		# Directory
		# info "$target is a dir.."
		if confirm "Replace existing directory" "$dst" N; then
			remove=true
		else
			skip=true
		fi
	fi

	# Check if the file has to be removed
	if [[ "$remove" = true ]]; then

		if confirm "Backup to" "$dst.bak" Y; then
			debug "cp" "$target $target.bak"
		fi

		[ "$DRY_RUN" != true ] && \
			debug "rm" "$target"
	fi

	# Check if the symbolic link can be created
	if [[ "$skip" != true ]]; then

		[ "$DRY_RUN" != true ] && \
			debug "ln -s" "$source $target"

		success "Symlink" "$dst"
	fi

	# return 0
}

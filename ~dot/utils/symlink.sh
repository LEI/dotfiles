#!/usr/bin/env bash
# symlink.sh

# . lib/array.sh
# . utils/logger.sh
# . utils/prompt.sh

symlink_files() {
	local src="$1"
	shift
	local dst="$1"
	shift
	local depth=$1
	shift
	local max_depth=$1
	shift
	local ignore="$@"
	local file

	# Formatted paths
	local source=$(pretty_path $src)
	local destination=$(pretty_path $dst)

	# Should not happen
	[[ $depth -gt $max_depth ]] && {
		warn "Reached depth $depth" "$source/*" # "$destination/${file#$src/}/*"
		return 1
	}

	# Prompt the user
	confirm "Symlink $destination" "$source" Y || {
		warn "Aborting"
		return
	}

	debug "Depth" "$depth"

	for file in $src/*; do

		# echo "current depth: $depth"
		((IL+=1))

		# Exclude .dotignore files
		if in_array "${file#$src/}" ignore; then
			debug "Ignored" "${file#$src/}"

			((IL-=1))
			continue
		fi

		if [[ -f "$file" ]]; then
			# File found, trying to link
			do_symlink "$file" "$dst/${file#$src/}"
		elif [[ $depth -eq $max_depth ]] && [[ -d "$file" ]]; then
			# Reached max depth, symlink directories
			((depth-=1))
			do_symlink "$file" "$dst/${file#$src/}"
			# continue
		elif [[ $depth -lt $max_depth ]] && [[ -d "$file" ]]; then
			# Going deep into directory, self call
			((depth+=1))
			debug "Symlink files nested call" "Going deep: $depth"
			symlink_files "$file" "$dst/${file#$src/}" $depth $max_depth "$ignore" && {
				success "$destination/${file#$src/}" "$source"
				((IL-=1))
				continue
			} || {
				((IL-=2))
				return 1
			}
		else
			error "${file#$src/}" "is a weird file" # && return 1
		fi

		((IL-=1))

	done

	return
}

do_symlink() {
	local src=$1
	local dst=$2
	# local backup=false
	local remove=false
	local skip=false # Do not skip by default

	# Formatted paths
	local source=$(pretty_path $src)
	local destination=$(pretty_path $dst)

	if [[ -h "$dst" ]] && [[ ! -e "$dst" ]]; then
		# Broken link
		error "Broken link $destination" "$source"
		if confirm "Remove $destination" "$source" Y; then
			remove=true
		else
			skip=true
		fi
	elif [[ -h "$dst" ]]; then
		# Symbolic link (-o -L?)
		local dst_link=$(readlink $dst)
		if [[ "$dst_link" == "$src" ]]; then
			success "Already linked $destination" "$source"
			skip=true
		else
			warn "$destination already linked" "$dst_link"
			if confirm "Remove link $dst_link" "$source" N; then
				remove=true
			else
				skip=true
			fi
		fi
	elif [[ -f "$dst" ]]; then
		# File
		if confirm "Replace existing file $destination" "$source" Y; then
			remove=true
		else
			skip=true
		fi
	elif [[ -d "$dst" ]]; then
		# Directory
		# info "$dst is a dir.."
		if confirm "Replace existing directory $destination" "$source" N; then
			remove=true
		else
			skip=true
		fi
	fi

	# Check if the file has to be removed
	if [[ "$remove" = true ]]; then

		if confirm "Backup $destination" "$destination.bak" Y; then
			debug "cp" "$dst $dst.bak" # todo check..
		fi

		[ "$DRY_RUN" != true ] && \
			debug "rm" "$dst"
	fi

	# Check if the symbolic link can be created
	if [[ "$skip" = true ]]; then
		info "Skipped $destination" "$source"
	else

		[ "$DRY_RUN" != true ] && \
			debug "ln -s" "$src $dst"

		success "Symlink $destination" "$source"
	fi

	# return 0
}

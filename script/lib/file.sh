#!/usr/bin/env bash

# file.sh

# Return
# 2: File does not exists
# 3: Target already exists

find_files() {
	local path=$1
	local exclude=${2-}

	[[ -n "$exclude" ]] && exclude="! -name $exclude "

	find ${path} -prune ${exclude}-print # \
		#2> >(grep -i -v "no such file or directory" >&2 || log_error "No such file or directory")
	# -ok {} \;

	# local cmd=""
	# printf "%s" "$cmd"
}

link_file() {
	local file=$1
	local dest=$2

	[[ ! -e "$file" ]] && return 2
	[[ -e "$dest" ]] && return 3

	dry_run "ln -s $file $dest"
}

backup_file() {
	local file=$1
	local backup_ext="bak"

	[[ ! -e "$file" ]] && return 2
	[[ -e "$file.$backup_ext" ]] && return 3

	dry_run "mv $file $file.$backup_ext"
}

remove_file() {
	local file=$1

  # TODO:
  # Check if file exists or broken symlink
  # Handle recursive with -r
	#[[ ! -e "$file" ]] && return 2
	[[ -d "$file" ]] && die "$file: is a directory"

	dry_run "rm $file"
}

readlink_file() {
	local file=$1

	[[ -e "$file" ]] || return 2

	local link=$(readlink "$file")
	printf "%s" "$link"
}

sed_file() {
	local file=$1
	local template=$2
	local variables=$3
	local var value
	local sed_command="sed "

	[[ -f "$template" ]] || return 1

	for var in ${variables[@]}; do
		value="\$$var"
		sed_command+="-e \"s/${var}/${value}/g\" "
	done
	sed_command+="${template} > ${file}"

	eval "$sed_command" || return 2
}

typeof_file() {
	local file=$1
	local is

	if [[ -h "$file" ]]; then
		is="link"
	elif [[ -f "$file" ]]; then
		is="file"
	elif [[ -d "$file" ]]; then
		is="directory"
	elif [[ ! -e "$file" ]]; then
		is=
	else # [[ -e "$file" ]]
		is="weird"
	fi

	printf "%s" "$is"
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

# _symlink_file() {
#
# 		if [[ -h "$dst" ]] && [[ ! -e "$dst" ]]; then
# 			# Broken link
# 			error "Broken link $destination" "$source"
# 			if confirm "Remove $destination" "$source" Y; then
# 				remove=true
# 			else
# 				skip=true
# 			fi
# 		elif [[ -h "$dst" ]]; then
# 			# Symbolic link (-o -L?)
# 			local dst_link=$(readlink $dst)
# 			if [[ "$dst_link" == "$src" ]]; then
# 				success "Already linked $destination" "$source"
# 				skip=true
# 			else
# 				warn "$destination already linked" "$dst_link"
# 				if confirm "Remove link $dst_link" "$source" N; then
# 					remove=true
# 				else
# 					skip=true
# 				fi
# 			fi
# 		elif [[ -f "$dst" ]]; then
# 			# File
# 			if confirm "Replace existing file $destination" "$source" Y; then
# 				remove=true
# 			else
# 				skip=true
# 			fi
# 		elif [[ -d "$dst" ]]; then
# 			# Directory
# 			# info "$dst is a dir.."
# 			if confirm "Replace existing directory $destination" "$source" N; then
# 				remove=true
# 			else
# 				skip=true
# 			fi
# 		fi
#
# 		# Check if the file has to be removed
# 		if [[ "$remove" = true ]]; then
#
# 			if confirm "Backup $destination" "$destination.bak" Y; then
# 				debug "cp" "$dst $dst.bak" # todo check..
# 			fi
#
# 			[ "$DRY_RUN" != true ] && \
# 				debug "rm" "$dst"
# 		fi
#
# 		# Check if the symbolic link can be created
# 		if [[ "$skip" = true ]]; then
# 			info "Skipped $destination" "$source"
# 		else
#
# 			[ "$DRY_RUN" != true ] && \
# 				debug "ln -s" "$src $dst"
#
# 			success "Symlink $destination" "$source"
# 		fi
# }

# _fill_files () {
# 	info "Using configuration file" "~${CONFIG_FILE#$HOME}"
#
# 	# Sample files
# 	for sample in ${sample_files[@]}; do
# 		local sample_param=(${sample//=/ })
# 		local cfg_name=${sample_param[0]}
# 		local cfg_path=${sample_param[1]}
# 		((indent_level++))
# 		# Create config file if needed
# 		if [ ! -f "$cfg_path" ]; then
# 			if ask "Create $cfg_path ?" Y; then
# 				_fill_file "$cfg_name" "$cfg_path" "name" "email" "credential"
# 				success "$cfg_name" "$cfg_path created"
# 			else
# 				skipped "$cfg_name" "$cfg_path"
# 			fi
# 		else
# 			success "$cfg_name" "$cfg_path already exists" true
# 		fi
# 		((indent_level--))
# 	done
# 	success "$USER" "Profiles configured"
#
# 	echo ''
# 	info "$(uname)" "Specific steps" true
# }
#
# _fill_file () {
# 	local name=$(echo "$1" | tr '[:lower:]' '[:upper:]')
# 	local path=$2
# 	shift
# 	shift
#
# 	local sed_cmd="sed "
# 	for var in $@; do
# 		local variable=$(echo "$var" | tr '[:lower:]' '[:upper:]')
# 		local value=$(eval echo \$$variable)
# 		sed_cmd+="-e \"s/${name}_${variable}/$value/g\" "
# 	done
# 	sed_cmd+="${path}sample > ${path}"
#
# 	eval "$sed_cmd"
# }

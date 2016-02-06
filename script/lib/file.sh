#!/usr/bin/env bash

# file.sh

sed_file() {
	local file=$1
	local template=$2
	local variables=$3
	local sed_command="sed "
	local var value

	[[ -f "$template" ]] || return 1

	for var in ${variables[@]}; do
		value=$(eval echo \$$var)
		sed_command+="-e \"s/${var}/${value}/g\" "
	done
	sed_command+="${template} > ${file}"

	eval "$sed_command" || return 2
}

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

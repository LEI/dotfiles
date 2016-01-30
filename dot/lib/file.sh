#!/bin/bash
# file.sh

# Eval configuration file
eval_file() {
	local file=$1
	local line

	while read line; do
		# Skip empty lines
		[[ -z "${line}" ]] && continue
		# Skip comments
		[[ ${line:0:1} == "#" ]] && continue

		content+=("$line")

		eval ${line}

	done < "${file}"
}

# File as array
read_file() {
	local file=$1
	local content=
	local line

	while read line; do # TODO: use -a
		# Skip empty lines
		[[ -z "${line}" ]] && continue
		# Skip comments
		[[ ${line:0:1} == "#" ]] && continue

		content+=("$line")
	done < "${file}"

	echo "${content[@]}"
}

# Check bash line
# valid_line() {
# 	local line=$1
# 	# Skip empty lines
# 	[[ -z "${line}" ]] && return 1
# 	# Skip comments
# 	[[ ${line:0:1} == "#" ]] && return 1
#
# 	return 0 # true
# }

pretty_path() {
	local path="$@"

	# Tilfify
	if [[ $path =~ $HOME* ]]; then
		echo "~${path#$HOME}"
	else
		echo "$path"
	fi
}

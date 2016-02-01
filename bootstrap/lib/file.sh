#!/usr/bin/env bash

# file.sh

# import "lib/log"

read_conf() {
	local file="$1"
	local section
	while IFS="= " read -r key value; do
		[[ -z "$key" ]] && continue # Empty
		[[ ${key:0:1} == "#" ]] && continue # Comment
		if [[ "$key" = \[*\] ]]; then
			section=${key#*[}
			section=${section%]*}
		else
			CONFIG["${section}_${key}"]=$value
		fi

	done < "$file"
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

process_template_file() {
	local file="$1"
	log_warn "TODO" "Process template ${file/$DOT_FILES\/}"
}

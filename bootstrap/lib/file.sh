#!/usr/bin/env bash

# file.sh

# import "lib/log"

read_conf() {
	local section
	while IFS="= " read -r key value; do
		[[ -z "$key" ]] && continue # Empty
		[[ ${key:0:1} == "#" ]] && continue
		if [[ "$key" = \[*\] ]]; then
			section=${key#*[}
			section=${section%]*}
		else
			CONFIG["${section}_${key}"]=$value
		fi

	done < "$1"
}

process_template_file() {
  local file="$1"
  log_warn "Process template ${file/$DOT_FILES\/}" "TODO"
}

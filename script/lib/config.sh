#!/usr/bin/env bash

# config.sh

import "lib/log"
import "lib/prompt"

# declare -a CONFIG

config() {
	local file="$1"
	local section

	if [[ ! -f "$file" ]] && \
		ask "Create configuration file" "$file " Y && \
		fill_config "$file" || \
		[[ -f "$file" ]]; then

		while IFS="= " read -r key value; do
			[[ -z "$key" ]] && continue # Empty line
			[[ ${key:0:1} == "#" ]] && continue # Comment
			if [[ "$key" = \[*\] ]]; then
				section=${key#*[}
				section=${section%]*}
				section="DOT_$section"
			elif [[ -n "${section}" ]]; then
				# CONFIG["${section}_${key}"]=$value
				if [[ -n "$value" ]]; then
					section=$(echo "${section}_${key}" | tr "[:lower:]" "[:upper:]")
					# Assign the value to a variable
					eval ${section}=\"\$value\"
				else
					section=$(echo "$section" | tr "[:lower:]" "[:upper:]")
					# Push the value to an array
					eval $section+=\(\"$key\"\)
				fi
			fi
		done < "$file"

		log_success "Configuration loaded" "$file"
	else
		log_error "Could not load" "$file"
		return 1
	fi
}

fill_config() {
	local file=$1
	local path=${file%/*}
	local name=${file##*/}
	local template="$path/template$name"

	if [[ -f "$template" ]]; then
		AUTHOR_NAME=$(prompt "What is your full name ?")
		AUTHOR_EMAIL=$(prompt "What is your email ?")
		sed -e "s/AUTHOR_NAME/\"$AUTHOR_NAME\"/g" \
			-e "s/AUTHOR_EMAIL/\"$AUTHOR_EMAIL\"/g" \
			$template > $file
	else
		log_error "Not a file" "$file"
		return 1
	fi
}

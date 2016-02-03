#!/usr/bin/env bash

# config.sh

import "log"
import "prompt"

# declare -a CONFIG

config() {
	local file="$1"
	local section var

	if [[ -f "$file" ]] || ( [[ ! -f "$file" ]] && \
		confirm "Create configuration file" "$file" Y && \
		fill_config "$file" ); then # Create new config

		while IFS="= " read -r key value; do
			# echo "$key $value"

			[[ -z "$key" ]] && continue # Empty line
			[[ ${key:0:1} == "#" ]] && continue # Comment

			if [[ "$key" = \[*\] ]]; then # Section
				section=${key#*[}
				section=${section%]*}
				section="DOT_$section"

			elif [[ -n "$section" ]]; then
				# CONFIG["${section}_${key}"]=$value

				if [[ -n "$value" ]]; then # Key = value
					var=$(echo "${section}_${key}" | tr "[:lower:]" "[:upper:]")
					# Assign the value to a variable (DOT_SECTION_VAR)
					eval ${var}=$value
					# echo ${var}=$value
				else # Value
					section=$(echo "$section" | tr "[:lower:]" "[:upper:]")
					# Push the value to an array (DOT_SECTION)
					eval $section+=\(\"$key\"\)
					# echo "$section+=\(\"$key\"\)"
				fi

			fi

		done < "$file"

	else
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
	fi
}

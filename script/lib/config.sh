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

		while IFS=$'=\n' read -r key value; do

			[[ -z "$key" ]] && continue # Empty line
			[[ ${key:0:1} == "#" ]] && continue # Comment
			key=${key% #*} # Remove inline comments (everything after ' #')
			key=${key%[[:space:]]} #key=${key%[[:space:]]*}
			# ${var%%[![:space:]]*} # Remove leading spaces
			# ${var##*[![:space:]]} # Remove trailing spaces
			value=${value#[[:space:]]}

			# echo "key: $key / value: <$value>"

			if [[ "$key" =~ [\[a-zA-Z0-9\]] ]]; then # Section
				section=${key#*[} # Left
				section=${section%]*} # Right
				section="DOT_$section" # Variable name
			elif [[ -n "${section-}" ]]; then
				if [[ -n "$value" ]]; then # Key = value
					var=$(echo "${section}_${key}" | tr "[:lower:]" "[:upper:]") # | tr -d "[[:space:]]"

					log_debug "${var}=$value"
					eval ${var}=$value # Assign the value to a variable (DOT_SECTION_VAR)

				else # No inline separator, single value
					section=$(echo "$section" | tr "[:lower:]" "[:upper:]")

					log_debug "$section+=\(\"$key\"\)"
					eval $section+=\(\"$key\"\) # Push the value to an array (DOT_SECTION)

				fi
			else
				die "Unrecognized section: $key $value"
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
		AUTHOR_NAME=$(prompt "What is your full name ?" "Guillaume Frichet")
		AUTHOR_EMAIL=$(prompt "What is your email ?" "guillaume.frichet@gmail.com")
		AUTHOR_USERNAME=$(prompt "What is your user name ?" "LEI")
		sed -e "s/AUTHOR_NAME/\"$AUTHOR_NAME\"/g" \
			-e "s/AUTHOR_EMAIL/\"$AUTHOR_EMAIL\"/g" \
			-e "s/AUTHOR_USERNAME/\"$AUTHOR_USERNAME\"/g" \
			$template > $file
	fi
}

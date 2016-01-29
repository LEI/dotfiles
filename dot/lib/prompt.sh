#!/bin/bash
# prompt.sh

# Basic prompt (y/N)
confirm() {
	local question=$1
	local answer

	local TAB="    "

	# Empty string as last parameter to prevent line return
	ask "$question " "" # >&2
	while true; do
		# read -e -p "$(ask "$question ")" answer
		read answer
		case $answer in
			[Yy]*)
				answer="y"
				break
			;;
			[Nn]*)
				answer="n"
				break # return 1
			;;
			*)
				warn "${TAB}Invalid answer" >&2
				confirm "$question"
				return 1
			;;
		esac
	done

	# Handle answer
	case $answer in
		y)  info "${TAB}Yes"
			return
		;;
		n)  info "${TAB}No"
			return 1
		;;
	esac
}

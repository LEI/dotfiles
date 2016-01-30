#!/bin/bash
# prompt.sh

# . utils/logger.sh

prompt() {
	local q=$1
	local answer
	# Display question
	ask "$q"
	# Wait for answer
	read -e answer
	[[ -n "$answer" ]] || (prompt "$@" && return)

	echo "$answer"
}

# Basic prompt (y/N)
confirm() {
	local q=$1 # question
	local p=$2 # path
	local default=${3-N}
	local choices

	case $default in
		Y) choices="Y/n" ;;
		N) choices="y/N" ;;
	esac

	# Display question (with no crlf)
	ask "$q" "$p ($choices) " ""

	((indent_level+=1))

	# Read input
	while true; do

		# read -e -p "$(ask "$q ")" answer
		#  -p ""
		# -e -> erase line??
		read -r answer
		# echo -en "\033[1A\033[2K"
		# local answer=$(prompt "$q")
		case $answer in
			[yY]*)
				answer=Y
				break
			;;
			[nN]*)
				answer=N
				break
			;;
			'')
				answer=$default
				# printf "%s\r\n" "$default"
				break
			;;
			*) # Unrecognized input, ask again (still no crlf)
				warn "Invalid answer" "'$answer' ($choices) " ""
			;;
		esac

	done

	# Handle final answer
	local code
	case $answer in
		Y) log "Yes"; code=0 ;;
		N) log "No"; code=1 ;;
		*) error "Unknown answer" "$answer"; code=2 ;;
	esac

	((indent_level-=1))

	return $code
}

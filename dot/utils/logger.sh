#!/bin/bash
# logger.sh

# . lib/colors.sh

# Usage:
# $1	Message string
# $2	Additional info
# $3	Optional end of line

log() {
	local message=$1
	local path=${2-}
	local crlf=${3-"\r\n"}
	# echo "$@"
	print $end "›" "$message" "$path" "$crlf"
}

info() {
	local message=$1
	local path=${2-}
	local crlf=${3-"\r\n"}
	# ›
	print $blue "i" "$message" "$path" "$crlf"
	# printf "%s\n" "${path[@]}"
}

ask() {
	local message=$1
	local path=${2-}
	local crlf=${3-"\r\n"}
	# ?
	print $yellow "?" "$message" "$path" "$crlf"
}

debug() {
	local message=$1
	local path=${2-}
	local crlf=${3-"\r\n"}

	# * >
	if [[ "$DEBUG" = true ]]; then
		print $cyan ">" "$message" "$path" "$crlf"
	fi
}

success() {
	local message=$1
	local path=${2-}
	local crlf=${3-"\r\n"}
	# ✓ ✔
	print $green "✔" "$message" "$path" "$crlf"
}

error() {
	local message=$1
	local path=${2-}
	local crlf=${3-"\r\n"}
	# × ✕ ✖ ✗ ✘
	print $red "✘" "$message" "$path" "$crlf"
}

warn() {
	local message=$1
	local path=${2-}
	local crlf=${3-"\r\n"}
	# ⚠ !
	print $yellow "!" "$message" "$path" "$crlf"
}

print() {
	local color=$1
	local symbol=$2 # log level
	local message=$3
	local path=$4
	local crlf=$5

	local date=""
	[[ "$TIMESTAMPS" = true ]] && date="[$(date +%H:%M:%S)] "

	# Build indentation
	local i=0
	local indent=
	while [[ $i -lt ${indent_level-0} ]]; do
		((i+=1)) #
		if [[ $(( $i % ${#indent_unit} )) -eq 0 ]]; then
			# Add pipe guides
			indent+="${indent_separator-|}${indent_unit:1}"
		else
			indent+="${indent_unit}"
		fi
		#
	done

	# Float right
	local column=$(tput cols)
	local col=$(( (${column-25} / 3) - ($i * ${#indent_unit}) )) # - ${#message}
	# echo "$message -> ${column-25} / 3 - ($i * ${#indent_unit-}) = $col"
	printf "$date%b%b %-${col}b %b%b" "$indent" "$color$symbol" "$message$end" "$path" "$crlf"
	# printf "$date%${p}b %b %b%b" "$symbol" "$message" "$path" "$crlf"

	# printf -v line '%*s' "$level"
	# echo ${line// /-}
}

# carriage_return() {
# 	printf "\r"
# }
#
# line_feed() {
# 	printf "\n"
# }

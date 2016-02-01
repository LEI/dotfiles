#!/usr/bin/env bash
# logger.sh

# . lib/colors.sh

# Usage:
# $1	Message string
# $2	Additional info
# $3	Replace end of line

log() {
	local message=$1
	local path=${2-}
	local crlf=${3-"\r\n"}
	# echo "$@"
	pprint $nc "›" "$message" "$path" "$crlf"
}

info() {
	local message=$1
	local path=${2-}
	local crlf=${3-"\r\n"}
	# ›
	pprint $blue "i" "$message" "$path" "$crlf"
	# printf "%s\n" "${path[@]}"
}

ask() {
	local message=$1
	local path=${2-}
	local crlf=${3-"\r\n"}
	# ?
	pprint $yellow "?" "$message" "$path" "$crlf"
}

debug() {
	local message=$1
	local path=${2-}
	local crlf=${3-"\r\n"}

	# $ * >
	if [[ "$DEBUG" = true ]]; then
		pprint $purple ">" "$message" "$path" "$crlf"
	fi
}

success() {
	local message=$1
	local path=${2-}
	local crlf=${3-"\r\n"}
	# ✓ ✔
	pprint $green "✔" "$message" "$path" "$crlf"
}

error() {
	local message=$1
	local path=${2-}
	local crlf=${3-"\r\n"}
	# × ✕ ✖ ✗ ✘
	pprint $red "✘" "$message" "$path" "$crlf"
}

warn() {
	local message=$1
	local path=${2-}
	local crlf=${3-"\r\n"}
	# ⚠ !
	pprint $yellow "!" "$message" "$path" "$crlf"
}

now() {
	local date=""
	[[ "$TIMESTAMPS" = true ]] && date="[$(date +%H:%M:%S)] "
	printf "%s" "$date"
}

print() {
	printf "%b\r\n" "$@"
}

# Pretty print
pprint() {
	local color=$1
	local symbol=$2 # log level
	local message=$3
	local path=$4
	local crlf=$5

	local date=$(now)

	# Build indentation
	local i=0
	local indent=

	# Float right
	local column=$(tput cols)
	local div=4
	local col=$(( (${column-25} / $div) - (${IL-0} * ${#IU}) )) # - ${#message}

	while [[ $i -lt ${IL-0} ]]; do
		if [[ $(( $i % ${#IU} )) -eq 1 ]]; then
			# Add pipe guides
			indent+="${IS}${IU:${#IS}}"
		else
			indent+="${IU}"
		fi
		((i+=1)) #
		#
	done
	# echo "$message -> ${column-25} / 3 - ($i * ${#IU-}) = $col"
	printf "$date%b%b %-${col}b %b%b" "$indent" "$color$symbol" "$message$nc" "$path" "$crlf"
	# printf "$date%${p}b %b %b%b" "$symbol" "$message" "$path" "$crlf"

	# printf -v line '%*s' "$level"
	# echo ${line// /-}
}

# STDIN
logger() {
	local date=$(now)

	while read data; do
		print "$date$data"
	done
}

#!/bin/bash
# logger.sh

# . colors

info() {
	# ›
	log $blu "›" "$@"
}

success() {
	# ✓ ✔
	log $grn "✓" "$@"
}

debug() {
	# 🐞
	if [[ "$DEBUG" = true ]]; then
		log $cyn "*" "$@"
	fi
}

warn() {
	# ⚠
	log $yel "⚠" "$@"
}

error() {
	# × ✕ ✖ ✗ ✘
	log $red "✗" "$@" #
}

log() {
	local color=$1
	local level=$2
	local message=$3

	printf "[$(date +%H:%M:%S)]  $color%b\t%s$end\r\n" "$level" "$message"
	# local date=$(date +%Y/%m/%d%H:%M:%S)
	# echo -e "[$date] $@" >&2
}

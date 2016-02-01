#!/usr/bin/env bash
# bootstrap.sh

# .		Import
# >		Command
# ~		Link

set -o nounset
set -o errexit
# set -o xtrace
# set -o pipefail

# Disable job control
# set +m
# shopt -s lastpipe

# Extend matching operators
shopt -s extglob
# Loop on dotfiles
shopt -s dotglob
# Do not loop on empty directory
shopt -s nullglob
# Recursive globbing
shopt -s globstar

boot() {
	unset -f boot

	UNAME=$(uname -s) # Darwin|Linux
	env_check

	# Paths
	DOT_TARGET=$HOME
	DOT_FILES="$DOT_ROOT/files"
	DOT_BOOTSTRAP="$DOT_ROOT/dot"
	DOT_RC="$DOT_ROOT/.dotrc"

	# Load ./dot/*/* files by alphabetical order
	import "$DOT_BOOTSTRAP/*/*.sh"

	# Bootstrap configuration
	DRY_RUN=false
	DEBUG=false
	TIMESTAMPS=true
	MIN_DEPTH=1
	MAX_DEPTH=2

	IL=0 # Indent level
	IU="  " # Indent unit
	IS="|" # Indent separator |｜❘

	# Get options
	parse_args "$@"
	# TODO: DOT_TARGET // -> slashes cleanup

	strap
}

ask_smthg() {
	echo "$@"
}

strap() {
	unset -f strap

	# Read .dotrc [ignore] section
	# DOT_IGNORE=$(read_file "$DOT_RC" "ignore")
	read_file "$DOT_RC" "ignore"
	exit


	# Logs
	debug "Debug mode enabled" "$UNAME"
	[ "$DRY_RUN" = true ] && local msg="DRY RUN: "
	log "${msg-}$DOT_ROOT -> $DOT_TARGET"
	# info "${DOT_RC#$DOT_ROOT/}" "$DOT_IGNORE"

	local files=$(find_files "$DOT_FILES" "$DOT_IGNORE" $MIN_DEPTH $MAX_DEPTH)
	#  | while read file; do
	# 	files=("$file")
	# 	# confirm "Symlink" "$file" Y || {
	# 	# 	warn "Aborting"
	# 	# 	return
	# 	# }
	# done
	echo ">>> $files"


	# foreach "$DOT_ROOT" | exclude "$DOT_IGNORE" | logger #ignore "$DOT_IGNORE"
	# find $DOT_BOOTSTRAP/* -mindepth 1 -type f -exec printf "%s\r\n" '{}' \;


	# local not_path="-not ( -path "*${DOT_IGNORE[0]}" $(printf -- '-o -path "*%s" ' "${DOT_IGNORE[@]:1}") )"
	# echo "$not_path"
	# local exclude=$(find_exclude "$DOT_IGNORE")
	# find_exclude $DOT_IGNORE
	# find $DOT_ROOT/* -mindepth $MIN_DEPTH -maxdepth $MAX_DEPTH -print # | logger
	# -maxdepth 1
	# -okdir  {} \;



	# Create symbolic lins
	# symlink_files "$DOT_ROOT" "$DOT_TARGET" $DEPTH $MAX_DEPTH "$DOT_IGNORE" && \
	# 	success "Success $DOT_TARGET" "$DOT_ROOT" || (error "Something went wrong" && return 1)
	# foreach "$DOT_ROOT" | logger #| ignore "$DOT_IGNORE" | log
}

# Find ignore
# find_exclude() {
# 	local ignore=("$@")
# 	local string=
#
# 	if [[ ${#ignore} -gt 0 ]]; then
# 		echo "${ignore[*]}"
# 		local IFS=" "
# 		for name in ${ignore[@]}; do
# 			echo "$name"
# 		done
# 	fi
#
# 	# if [[ ${#ignore} -gt 0 ]]; then
# 	# 	string=$(_join " ! -name " ${ignore[@]})
# 	# 	# string="-not ( -name $string )"
# 	# fi
#
# 	printf "%s" "$string"
# }
#
# # Array join
# # _join() {
# #   separator=$1
# #   arr=$*
# #   arr=${arr:2} # throw away separator and following space
# #   arr=${arr// /$separator}
# # }
# _join() {
#    perl -e '$s = shift @ARGV; print join($s, @ARGV);' "$@";
# }
# # 1 char only
# array_join() {
# 	local IFS="$1"
# 	shift
# 	printf "%s" "$*"
# }

# Pipe function
foreach() {
	local fn=$1

	while read data; do
		$fn "$data"
	done
}

# Source files
import() {
	local file
	for file in $@; do
		# echo "source $file"
		if [[ -f "$file" ]]; then
			source "$file" || return 1
		fi
	done
}

env_check() {
	if [[ $USER == "root" ]]; then
		printf "%s\r\n" "Root detected, aborting."
		exit 1
	fi

	# local BASH_VERSION=$(bash --version)
	# printf "%s\r\n" "$BASH_VERSION"

  # local globstar=$(shopt -s globstar)
  # printf "%s" "$globstar"
}

boot "$@"

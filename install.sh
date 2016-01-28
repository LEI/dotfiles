#!/bin/bash
#
# Dotstrap bootfiles

set -o nounset
set -o errexit

dotfiles_path="${BASH_SOURCE[0]%/*}"
[ -f "$dotfiles_path" ] && dotfiles_path=$(dirname "$dotfiles_path")

main() {
	unset -f main

	load "${dotfiles_path}/script/*.sh"

	echo "All done" $dotfiles_path

	parse_args "$@"
}

# github.com/tomas/skull/blob/master/base/loader.sh
load() {
    for lib in $@; do
        if [ -d "$lib" ]; then
			load "$lib/*.sh"
        elif [ -f "$lib" ]; then
            source "$lib"
        fi
    done
    unset lib
}

usage() {
	unset -f usage

	echo "Whelp..."
}

# Parse arguments and unset recognized ones
parse_args() {
	unset -f parse_args

	# Strict mode IFS value
	IFS=$'\n\t'

	#local args=$# #("$@")

	for arg; do #in "$@"; do
		#echo ">>> argS $args , $@ <<<"
		log "arg $arg"
		if [ ! -z ${1} ]; then
			case $1 in
			
				-h|--help)
					usage
					break
				;;

				-v|--verbose)
					verbose=true
				;;

				-t|--target)
					#echo "TARGET pre $1 / $args , $@"
					shift
					#args=$(($args-2))
					target="$1"
					#echo "TARFET post $1 / $args , $@"
				;;

				*)
					log "Unknown option: $1"
					break
				;;

			esac
			shift
		else
			echo "unbound arg $@"
		fi
	done


	if [[ -n $1 ]]; then
    	echo "Last line of file specified as non-opt/last argument:"
    	tail -1 $1
	fi	
}

main "$@"

#for (( i = ${#args[@]} - 1; i >= 0; i-- )); do
#	case ${args[i]} in

#		-h|--help)
#			#echo_usage

#			unset args[i] ;;

#		-v|--verbose)
#			verbose=true

#			unset args[i] ;;

#		-*)
#			log "${args[i]}" "Unrecognized option"
#			#echo_usage

#			unset args[i] ;;

#	esac
#done

# Print echo_usage if > 1 argument left
#[ ${#args[@]} -gt 1 ] && echo_usage

#cmd=${args[@]}

#log "-> $cmd"

#while [[ $# -gt 0 ]]; do
#	local arg="$1"
#
#	case $arg in
#		-h|-help)
#			# usage
#		;;
#		-v|--verbose)
#			verbose=true
#		;;
#		-t|--target)
#			target="$2"
#			shift
#		;;
#		*)
#			log "Unknown option: $@"
#		;;
#	esac
#	shift
#done

#if [[ -n $1 ]]; then
#   	echo "Last line of file specified as non-opt/last argument:"
#   	tail -1 $1
#fi


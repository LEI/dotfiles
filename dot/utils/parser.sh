#!/bin/bash
# parser.sh

# Parse arguments
parse_args() {
	# [ $# -gt 0 ] || return 0;
	# debug "Parsing $# arguments: '$@'"
	while [ $# -gt 0 ]; do

		debug "Parsing $1 (#$#)"

		case $1 in
			--dry-run)
				shift
				DRY_RUN=true
			;;
			-d|--debug)
				shift
				DEBUG=true
			;;
			-o|--out)
				shift
				# if [ $# -gt 0 ]; then # handle no param
					OUTPUT=$1
					shift
					# isset= [[ -n ${1-} ]]
					while [ $# -gt 0 ] && [[ $1 != -* ]]; do # handle spaces
						OUTPUT="$OUTPUT $1"
						shift
					done
				# elif
				# 	warn "Missing parameter: --out <param>"
				# 	usage 1
				# fi
			;;
			-h|--help)
				usage # exit 0
			;;
			*)
				warn "Unrecognized option: '$1'"
				usage 1 # exit 1
			;;
		esac
	done
}

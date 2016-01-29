#!/bin/bash
# parser.sh

# . dot/lib/usage.sh

# Parse arguments
parse_args() {
	# [ $# -gt 0 ] || return 0;
	# echo "Parsing $# arguments: '$@'"
	while [ $# -gt 0 ]; do
		# echo "Parsing $1 (#$#)"
		case $1 in
			--dry-run)
				shift
				DRY_RUN=true
			;;
			-d|--debug)
				shift
				DEBUG=true
			;;
			-t|--target)
				shift
				[ $# -gt 0 ] || usage 1; # handle empty value
				DOT_TARGET=$1
				shift
				# isset= [[ -n ${1-} ]]
				while [ $# -gt 0 ] && [[ $1 != -* ]]; do # handle spaces?
					TARGET="$TARGET $1"
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
				usage 1 "Unrecognized option: '$1'" # exit 1
			;;
		esac
	done
}

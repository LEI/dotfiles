#!/bin/bash
# parser.sh

# . lib/usage.sh
# . utils/logger.sh

# Handle arguments
parse_args() {
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
				echo "Debug mode enabled"
				;;
			-t|--target)
				shift
				# Handle empty parameter
				[ $# -gt 0 ] || usage 1 "Missing value for: --target";
				# Change dotfiles destination
				DOT_TARGET=$1
				shift
				# Can't handle " -" in file names
				while [ $# -gt 0 ] && [[ $1 != -* ]]; do
					DOT_TARGET="${DOT_TARGET-} $1"
					shift
				done
				;;
			-h|--help)
				usage
				;;
			*)
				usage 1 "Unrecognized option: '$1'"
				;;
		esac
	done
}

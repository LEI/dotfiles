#!/bin/bash
# parser.sh

# . lib/usage.sh
# . utils/logger.sh

# Handle arguments
parse_args() {
	# echo "Parsing $# arguments: '$@'"
	while [[ $# -gt 0 ]]; do
		local key=$1
		local val=${2-} # Can be undefined
		# echo "Parsing $1 (#$#)"
		case $key in
			--dry-run)
				DRY_RUN=true
				shift
				;;
			--depth)
				check_int + $val || usage 1 "Invalid option: $key $val"
				MAX_DEPTH=$val
				shift 2
				# usage 2 "Don't try this"
				;;
			-d|--debug)
				DEBUG=true
				shift
				;;
			-t|--target)
				shift

				# Loop until next '-', cannot handle ' -' without quotes
				# while [[ $# -gt 0 ]] && [[ $1 != -* ]]; do
				# 	DOT_TARGET+=" $1"
				# 	shift
				# done

				# If args left, check value not starting with the command delimiter '-'
				if [[ $# -gt 0 ]] && [[ ! -z "$val" ]] && [[ $val != -* ]]; then
					shift
				else
					# Ask for the missing value
 					local prompt="Please specify a target path (default: $HOME): "
 					read -e -r -p "$prompt" val # -i "$HOME"
 					# Use default
 					[[ -z "$val" ]] && break
				fi
				# Check destination path
				[[ -d "$val" ]] || usage 1 "Not a directory: $key $val"
				DOT_TARGET="$val"
				;;
			-h|--help)
				usage
				;;
			*)
				usage 1 "Unknown option: $key"
				;;
		esac
	done
}

check_int() {
	local sign=$1
	local val=${2-}

	if [[ "$val" =~ ^([0-9]+)$ ]]; then
		case $sign in
			+) [[ "$val" -ge 0 ]] && return ;;
			-) [[ "$val" -le 0 ]] && return ;;
		esac
	fi

	return 1
}

# parse_opt() {
	# local opts=
	# local name=$1
	# shift
	# # Handle empty parameter
	# [[ $# -gt 0 ]] || usage 1 "Missing value for: $name";
	# local cmd="$@"
	# while [[ $# -gt 0 ]] && [[ $1 != -* ]]
	# while IFS="-" read -r -a opts; do
	# 		# Stop reading
	# 		[[ $# -eq 0 ]] && break
	# 		printf "%s\n" "${opts[0]}"
	# 		# shift
	# done <<< "$cmd"


	# local opts="$1"
	# shift
	# # Can't handle " -" in file names
	# while [[ $# -gt 0 ]] && [[ $1 != -* ]]; do
	# 	# Add a space to reconstruct
	# 	opts+=" $1"
	# 	shift
	# done
	# printf "%s" "$opts"
# }

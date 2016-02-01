#!/usr/bin/env bash
# file.sh

# Search
find_files() {
	local path="$1"
	local ignore="$2"
	local min_depth=${3-1}
	local max_depth=${4-1}
	local depth=0

	[[ $min_depth -gt $max_depth ]] && echo "DEEP ERROR" && return 1

	# Starting depth
	while [[ $min_depth -gt $depth  ]]; do
		path+="/*" # only dir ? += /
		(( depth += 1 ))
	done

	# echo "FOREACH $path $min_depth $max_depth"

	for file in $path; do

	  # for i in ${ignore[@]}; do
		# 	echo "[[ $file =~ $i ]]"
	  #   if [[ $file =~ $i ]]; then
		# 		echo "IGNORED $file"
		# 		break
		# 		continue
	  #   fi
	  # done

		if excluded "${file#$path}" "${ignore[@]}"; then
			echo "IGNORED: $file"
		elif [[ -f "$file" ]]; then
			# echo "-F"
			printf "%s\r\n" "$file"
		elif [[ -d "$file" ]]; then

			# [[ "$directory" == true ]] && echo "ABORT $file" && return
			# echo "-D $min_depth"
			(( min_depth++ ))
			echo find_files "$path" "" $min_depth $max_depth true
		else
			echo "ERR: $file"
		fi
	done
}

excluded() {
  local needle=$1
  local haystack=$2
  local in=1


  # echo "needle: $needle, hay: ${!haystack}"
  echo "Searching '$needle' in '$haystack' ${#haystack}"
  for element in $haystack; do
    echo "[[ $element =~ $needle ]] ${haystack[0]}"
    # if [[ $element =~ $needle ]]; then
    #   in=0
    #   break
    # fi
  done

  return $in
}

# ignore() {
# 	local ignore="$1"
#
#
# 	while read path; do
# 		echo "i:*$path"
# 		# for glob in $ignore; do
# 		# 	[[ $path =~ $glob ]] && echo "$path / $glob" || echo "$path /// $glob"
# 		# done
#
# 		# [[ $ignore =~ *$file* ]] printf "%s" "$file"
# 	done
#
# 	# if in_array "${file#$src/}" ignore; then
# 	# 	debug "Ignored" "${file#$src/}"
# 	# 	continue
# 	# fi
#
# 	# printf "ex: %s\n" "$p"
# }

# Eval configuration file
eval_file() {
	local file=$1
	local line

	while read line; do
		# Skip empty lines
		[[ -z "${line}" ]] && continue
		# Skip comments
		[[ ${line:0:1} == "#" ]] && continue

		content+=("$line")

		eval ${line}

	done < "${file}"
}

# File as array
read_file() {
	local file=$1
	local section=${2-*}
	local current_section=
	local line

	# local IFS=$"\r\n"
	mapfile -t lines < "$file"
	echo ">${lines[@]}<"

	# local IFS=
	for line in ${lines[@]}; do
		# Remove leading white space
		echo "$line"
		line=${line/#+([[:blank:]])/}
		# Skip empty lines
		[[ -z "${line}" ]] && continue
		# Skip comments
		[[ ${line:0:1} == "#" ]] && continue
		# Parse line
		[[ $line =~ \[*\] ]] && {
			# Remove session title brackets
			current_section=${line#*[}
			current_section=${current_section%]*}
		} || {
			# Output line if the current section matches
			[[ $current_section = $section ]] && printf "<%s>" "$line"
		}
	done
	# while read -r line; do
	# done < "${file}"
}

# Check bash line
# valid_line() {
# 	local line=$1
# 	# Skip empty lines
# 	[[ -z "${line}" ]] && return 1
# 	# Skip comments
# 	[[ ${line:0:1} == "#" ]] && return 1
#
# 	return 0 # true
# }

pretty_path() {
	local path="$@"

	# Tilfify
	if [[ $path =~ $HOME* ]]; then
		echo "~${path#$HOME}"
	else
		echo "$path"
	fi
}

#!/usr/bin/env bash

# import.sh

IMPORTED=()

import() {
	local path=$1
	local ext=${2-sh}
	local name="${path##*/}"
  name="${name%$ext}"

	if [[ ! -f "${DOT_SCRIPT}/${path}.${ext}" ]]; then
    die "${DOT_SCRIPT}/${path}.${ext} No such file" # return 1
  elif [[ ${IMPORTED[*]-} =~ $name ]]; then
    return 0  # Already loaded
  else
    IMPORTED+=("$path")
  	source "${DOT_SCRIPT}/${path}.${ext}"
  fi

  # for file in $DOT_SCRIPT/$path*.sh; then ?
	return $?
}

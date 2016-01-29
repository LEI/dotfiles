#!/bin/bash
# array.sh

# Searches array for needle
# Usage: contains array "$needle" && echo yes || echo no
in_array () {
    local needle=$1
    local haystack="$2[@]"
    local in=1

    # echo "Searching '$needle' in '${!haystack}'"

    for element in ${!haystack}; do
        if [[ $element == $needle ]]; then
            in=0
            break
        fi
    done

    return $in
}

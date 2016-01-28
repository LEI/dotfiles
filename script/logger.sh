#!/bin/bash

log() {
	# +%Y/%m/%d 
	local date=$(date +%H:%M:%S)

	echo -e "[$date] $@" >&2
}

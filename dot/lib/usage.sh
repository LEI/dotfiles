#!/bin/bash
# usage.sh

# Usage
usage() {
	unset -f usage

	local code=${1-0}
	shift
	local message=${1-}

	echo "$message"

	echo "
Usage: TODO
	"
	# echo "
	#
	#    Usage: dot [command] [options]
	#
	#    Commands:
	#
	#          dot install     dot
	#
	#             Execute all bootstrap steps.
	#             Run './bootstrap' one time in order to symlink '~/bin' and use 'dot'.
	#
	#          dot uninstall   undot
	#
	#             Remove symbolic links (files /*.$/ or bin/*) and copied files (directories /^.*/).
	#             Does not reverse 'dot defaults' and 'dot setup'.
	#
	#          dot defaults    ~/.dotfiles/defaults
	#
	#             Available on OS X only (for now) and may require to restart.
	#
	#          dot setup       ~/.dotfiles/setup
	#
	#             Check for Homebrew then install bundles with Brew and Cask
	#
	#    Options:
	#
	#          -a, --auto      Use predefined answers
	#          -d, --debug     Should only log (not ready yet)
	#          -f, --force     Do everything blindlessly
	#          -t, --test      Use another directory for symlink and copy
	#          -u, --ugly      Reset colors for light backgrounds
	#          -v, --verbose   Output external logs
	#          -h, --help      Show this message
	#
	# "

	exit $code
}

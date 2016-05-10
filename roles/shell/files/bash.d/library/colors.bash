#
# Bash colors
#

# https://github.com/Bash-it/bash-it/blob/master/themes/colors.theme.bash

# __() {
#   echo "$@"
# }

# __echo_ansi() {
#   next-$1; shift
#   echo "\[\e[$(__$next $@)m\]"
# }

# __echo() {
#   next-$1; shift
#   echo "\033[$(__$next $@)m"
# }

if tput setaf 1 &> /dev/null; then

  #tput sgr0; # reset colors
  bold=$(tput bold)
  reset=$(tput sgr0)
  black=$(tput setaf 0)
  red=$(tput setaf 1)
  green=$(tput setaf 2)
  yellow=$(tput setaf 3)
  blue=$(tput setaf 4)
  magenta=$(tput setaf 5)
  cyan=$(tput setaf 6)
  white=$(tput setaf 7)

  bblack=$(tput setaf 8)
  bred=$(tput setaf 9)
  bgreen=$(tput setaf 10) #bgreen
  byellow=$(tput setaf 11)
  bblue=$(tput setaf 12)
  bmagenta=$(tput setaf 13)
  bcyan=$(tput setaf 14)
  bwhite=$(tput setaf 15)

  #	tput sgr0; # reset colors
  #	bold=$(tput bold)
  #	reset=$(tput sgr0)
  #	# Solarized colors, taken from http://git.io/solarized-colors.
  #	black=$(tput setaf 0)
  #	blue=$(tput setaf 33)
  #	cyan=$(tput setaf 37)
  #	green=$(tput setaf 64)
  #	orange=$(tput setaf 166)
  #	purple=$(tput setaf 125)
  #	red=$(tput setaf 124)
  #	violet=$(tput setaf 61)
  #	white=$(tput setaf 15)
  #	yellow=$(tput setaf 136)
else
  bold=''
  reset="\e[0m"
  black="\e[1;30m"
  blue="\e[1;34m"
  cyan="\e[1;36m"
  green="\e[1;32m"
  orange="\e[1;33m"
  purple="\e[1;35m"
  red="\e[1;31m"
  violet="\e[1;35m"
  white="\e[1;37m"
  yellow="\e[1;33m"

  # reset='\033[0m'           # No color
  # black='\033[0;30m'        # Black
  # red='\033[0;31m'          # Red
  # green='\033[0;32m'        # Green
  # yellow='\033[0;33m'       # Yellow
  # blue='\033[0;34m'         # Blue
  # purple='\033[0;35m'       # Purple
  # cyan='\033[0;36m'         # Cyan
  # white='\033[0;37m'        # White
fi

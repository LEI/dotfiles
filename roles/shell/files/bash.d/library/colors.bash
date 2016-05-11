#!/usr/bin/env bash
#
# Bash colors
#

if tput setaf 1 &> /dev/null; then

  reset=$(tput sgr0)
  bold=$(tput bold)
  # blink=$(tput blink)
  # reverse=$(tput smso)
  # underline=$(tput smul)

  black=$(tput setaf 0)
  red=$(tput setaf 1)
  green=$(tput setaf 2)
  yellow=$(tput setaf 3)
  blue=$(tput setaf 4)
  magenta=$(tput setaf 5)
  cyan=$(tput setaf 6)
  white=$(tput setaf 7)
  orange=$(tput setaf 166)

  # Solarized colors, taken from http://git.io/solarized-colors
  # black=$(tput setaf 0)
  # blue=$(tput setaf 33)
  # cyan=$(tput setaf 37)
  # green=$(tput setaf 64)
  # magenta=$(tput setaf 125)
  # red=$(tput setaf 124)
  # violet=$(tput setaf 61)
  # white=$(tput setaf 15)
  # yellow=$(tput setaf 136)

  b_black=$(tput setaf 8)
  b_red=$(tput setaf 9)
  b_green=$(tput setaf 10)
  b_yellow=$(tput setaf 11)
  b_blue=$(tput setaf 12)
  b_magenta=$(tput setaf 13)
  b_cyan=$(tput setaf 14)
  b_white=$(tput setaf 15)
  b_orange=

else

  # https://github.com/Bash-it/bash-it/blob/master/themes/colors.theme.bash
  reset="\[\e[0m\]"
  bold="\[\e[1m\]"
  # reset_color="\[\e[39m\]" # Default foreground color

  black="\[\e[0;30m\]"
  red="\[\e[0;31m\]"
  green="\[\e[0;32m\]"
  yellow="\[\e[0;33m\]"
  blue="\[\e[0;34m\]"
  magenta="\[\e[0;35m\]"
  cyan="\[\e[0;36m\]"
  white="\[\e[0;37m\]"
  orange="\[\e[0;91m\]"

fi

bold_black="\[\e[30;1m\]"
bold_red="\[\e[31;1m\]"
bold_green="\[\e[32;1m\]"
bold_yellow="\[\e[33;1m\]"
bold_blue="\[\e[34;1m\]"
bold_magenta="\[\e[35;1m\]"
bold_cyan="\[\e[36;1m\]"
bold_white="\[\e[37;1m\]"
bold_orange="\[\e[91;1m\]"

underline_black="\[\e[30;4m\]"
underline_red="\[\e[31;4m\]"
underline_green="\[\e[32;4m\]"
underline_yellow="\[\e[33;4m\]"
underline_blue="\[\e[34;4m\]"
underline_magenta="\[\e[35;4m\]"
underline_cyan="\[\e[36;4m\]"
underline_white="\[\e[37;4m\]"
underline_orange="\[\e[91;4m\]"

background_black="\[\e[40m\]"
background_red="\[\e[41m\]"
background_green="\[\e[42m\]"
background_yellow="\[\e[43m\]"
background_blue="\[\e[44m\]"
background_magenta="\[\e[45m\]"
background_cyan="\[\e[46m\]"
background_white="\[\e[47m\]"
background_orange="\[\e[101m\]"

# These colors are meant to be used with `echo -e`
echo_normal="\033[0m"
echo_reset_color="\033[39m"

echo_black="\033[0;30m"
echo_red="\033[0;31m"
echo_green="\033[0;32m"
echo_yellow="\033[0;33m"
echo_blue="\033[0;34m"
echo_magenta="\033[0;35m"
echo_cyan="\033[0;36m"
echo_white="\033[0;37m"
echo_orange="\033[0;91m"

echo_bold_black="\033[30;1m"
echo_bold_red="\033[31;1m"
echo_bold_green="\033[32;1m"
echo_bold_yellow="\033[33;1m"
echo_bold_blue="\033[34;1m"
echo_bold_magenta="\033[35;1m"
echo_bold_cyan="\033[36;1m"
echo_bold_white="\033[37;1m"
echo_bold_orange="\033[91;1m"

echo_underline_black="\033[30;4m"
echo_underline_red="\033[31;4m"
echo_underline_green="\033[32;4m"
echo_underline_yellow="\033[33;4m"
echo_underline_blue="\033[34;4m"
echo_underline_magenta="\033[35;4m"
echo_underline_cyan="\033[36;4m"
echo_underline_white="\033[37;4m"
echo_underline_orange="\033[91;4m"

echo_background_black="\033[40m"
echo_background_red="\033[41m"
echo_background_green="\033[42m"
echo_background_yellow="\033[43m"
echo_background_blue="\033[44m"
echo_background_magenta="\033[45m"
echo_background_cyan="\033[46m"
echo_background_white="\033[47m"
echo_background_orange="\033[101m"

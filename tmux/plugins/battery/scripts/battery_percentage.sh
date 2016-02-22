#!/usr/bin/env bash

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

source "$CURRENT_DIR/helpers.sh"

print_battery_percentage() {
  # percentage displayed in the 2nd field of the 2nd row
  if command_exists "pmset"; then
    pmset -g batt | awk 'NR==2 { gsub(/;/,""); print $2 }'
  elif command_exists "upower"; then
    for battery in $(upower -e | grep battery); do
      upower -i $battery | grep percentage | awk '{print $2}'
    done | xargs echo
  elif command_exists "acpi"; then
    acpi -b | grep -Eo "[0-9]+%"
  fi
}

print_battery_level() {
  local status=$1
  local percentage=$(print_battery_percentage)
  local percent=${percentage%\%}
  local display_percentage=true
  local level=$(spark 0 $percent 100)
  local level_color= color=

  if [[ $percent -lt 25 ]]; then
    level_color="red"
  elif [[ $percent -ge 25 ]] && [[ $percent -lt 75 ]]; then
    level_color="yellow"
  elif [[ $percent -ge 75 ]]; then
    #display_percentage=false
    level_color=
  fi

  if [[ $status =~ (charged) ]]; then
    color="green"
  elif [[ $status =~ (^charging) ]]; then
    color="white"
  elif [[ $status =~ (^discharging) ]]; then
    color="$level_color"
  elif [[ $status =~ (attached) ]]; then
    color="brightred"
  fi

  #if [[ "$display_percentage" = true ]]; then
  #  percentage+=" "
  #else
  #  percentage=
  #fi

  printf "%s" "#[fg=${color}]${level:1:1}"
}

main() {
  local status=$(battery_status)
  print_battery_level "$status"
}
main

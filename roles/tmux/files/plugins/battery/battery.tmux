#!/usr/bin/env bash

# Custom tmux-battery plugin

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

source "$CURRENT_DIR/scripts/helpers.sh"

battery_percentage="#($CURRENT_DIR/scripts/battery_percentage.sh)"
#battery_remain="#($CURRENT_DIR/scripts/battery_remain.sh)"
#battery_symbol="#($CURRENT_DIR/scripts/battery_symbol.sh)"
battery_percentage_interpolation="\#{battery_percentage}"
#battery_remain_interpolation="\#{battery_remain}"
battery_symbol_interpolation="\#{battery_symbol}"

set_tmux_option() {
  local option="$1"
  local value="$2"
  tmux set-option -gq "$option" "$value"
}

do_interpolation() {
  local string="$1"
  local interp=

  interp="${string/$battery_percentage_interpolation/$battery_percentage}"
  #interp="${interp/$battery_remain_interpolation/$battery_remain}"
  #interp="${interp/$battery_symbol_interpolation/$battery_symbol}"

  echo "$interp"
}

update_tmux_option() {
  local option="$1"
  local option_value="$(get_tmux_option "$option")"
  local new_option_value="$(do_interpolation "$option_value")"
  set_tmux_option "$option" "$new_option_value"
}

main() {
  update_tmux_option "status-right"
  update_tmux_option "status-left"
}
main

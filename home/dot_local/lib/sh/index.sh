# shellcheck shell=bash

# Source all sibling helpers, skipping self
for _f in "${BASH_SOURCE[0]%/*}"/*.sh; do
  [ "$_f" = "${BASH_SOURCE[0]}" ] && continue
  # shellcheck disable=SC1090
  . "$_f"
done
unset _f

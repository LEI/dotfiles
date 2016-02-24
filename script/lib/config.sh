#!/usr/bin/env bash

# config.sh

import "lib/log"
import "lib/utils"
import "lib/prompt"
import "lib/file"

# Usage: config <file> [<template>]
config() {
  local file=$1
  local template=${2-}

  local file_name=$(tildify $file)

  # Fill config from template if needed
  if [[ ! -f "$file" ]]; then

    # If no template is specified, try to add .template
    if [[ -z "$template" ]]; then
      # local path=${file%/*}
      # local name=${file##*/}
      template="$file.template"
      log_warn "Assuming template location:" "${file_name}.template"
    fi

    confirm "Create configuration file" "$file_name" Y || return 1
    # Prefix is important
    DOT_USER_NAME=$(prompt "What is your full name" "Guillaume Frichet")
    DOT_USER_EMAIL=$(prompt "What is your email" "guillaume.frichet@gmail.com")
    DOT_USER_NICK=$(prompt "What is your nickname" "LEI")

    local vars=("${!DOT_USER_*}")
    # Generate .dotrc
    sed_file "$file" "$template" "${vars[@]}" || return 1
  fi

  [[ -f "$file" ]] || return 1

  if config_read "$file"; then
    log_success "Using configuration file" "$file_name"
  else
    log_error "Could not generate configuration file" "$file_name"
    return 1
  fi
}

config_read() {
  local file=$1
  local section var_name

  while IFS=$'=\n' read -r key value; do

    [[ -z "$key" ]] && continue # Empty line
    [[ ${key:0:1} == "#" ]] && continue # Comment

    # Remove inline comments (everything after ' #')
    key=${key%[[:space:]]#*}
    value=${value%[[:space:]]#*}

    # Trim (handle ' = ')
    key=${key#[[:space:]]}
    key=${key%[[:space:]]}
    value=${value#[[:space:]]}
    value=${value%[[:space:]]}
    # ${var_name%%[![:space:]]*} # Remove leading spaces
    # ${var_name##*[![:space:]]} # Remove trailing spaces

    if [[ "$key" =~ [\[a-zA-Z0-9\]] ]]; then # Section
      section=${key#*[} # Left
      section=${section%]*} # Right
      section="DOT_$section" # Variable name
    elif [[ -n "${section-}" ]]; then
      if [[ -n "$value" ]]; then # Key = value
        var_name=$(echo "${section}_${key}" | to_upper_case) # | tr -d "[[:space:]]"

        log_debug "${var_name}=\"$value\""
        eval ${var_name}=\"$value\" # Assign the value to a variable (DOT_SECTION_VARNAME)

      else # No inline separator, single value
        section=$(echo "$section" | to_upper_case)

        log_debug "$section+=\(\"$key\"\)"
        eval $section+=\(\"$key\"\) # Push the value to an array (DOT_SECTION)

      fi
    else
      die "Unrecognized section: $key $value"
    fi

  done < "$file"
}

# config_template() {
#   local file=$1
#   local template=$2
#
#   # If no template is specified, try to add .template
#   if [[ -z "$template" ]]; then
#     local path=${file%/*}
#     local name=${file##*/}
#     template="$path/$name.template"
#   fi
#
#   if [[ -f "$template" ]]; then
#     AUTHOR_NAME=$(prompt "What is your full name" "Guillaume Frichet")
#     AUTHOR_EMAIL=$(prompt "What is your email" "guillaume.frichet@gmail.com")
#     AUTHOR_USERNAME=$(prompt "What is your user name" "LEI")
#     sed -e "s/AUTHOR_NAME/\"$AUTHOR_NAME\"/g" \
#         -e "s/AUTHOR_EMAIL/\"$AUTHOR_EMAIL\"/g" \
#         -e "s/AUTHOR_USERNAME/\"$AUTHOR_USERNAME\"/g" \
#         $template > $file || return 1
#   else
#     return 1
#   fi
# }

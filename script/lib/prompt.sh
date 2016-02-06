#!/usr/bin/env bash

# prompt.sh

import "lib/log"

# Wait for line input
prompt() {
  local question=$1
  local placeholder=${2-}
  local valid_answer=${3-}
  local answer

  if [[ $ENV_BASH_VERSION -ge 4 ]] && [[ -n "$placeholder" ]]; then
    # Read with -i if bash > 4
    log_ask "$question" "" >&2
    read -e -r -i "$placeholder" answer

    [[ -n "$answer" ]] || (prompt "$@" && return)
  else
    local default_value=
    [[ -n "$placeholder" ]] && default_value="(default: $placeholder)"
    log_ask "$question" "$default_value" >&2
    read -e -r answer

    [[ -n "$answer" ]] || answer=$placeholder
  fi

  if [[ -n "$valid_answer" ]] && [[ "$answer" =~ [^$valid_answer] ]]; then
    # log_debug "Answer pattern" "$valid_answer" >&2
    log_warn "Invalid anwser, please retry" "($valid_answer) $answer" >&2
    prompt "$@" && return
  fi

  printf "%s" "$answer"
  return
}

# Wait for char input
confirm() {
  local question=$1
  local text=${2-}
  local default=${3-N}

  case $default in
    Y) choices="Y/n" ;;
    N) choices="y/N" ;;
    *) choices="y/n" ;;
  esac

  [[ "$text" != "" ]] && text="$text " # Add a space if not empty
  log_ask "$question" "$text($choices) " "" # Display the question
  # + space between choices and input ^  ^ replace \r\n

  # Ask
  while true; do

    if [[ "${FORCE-}" = true ]]; then
      answer=$default
      log_debug "Force" #"default $default"
      break
    fi

    # Read one char
    read -e -n 1 answer # -r # -s -n 1

    case $answer in
      [yY]*)
        answer=Y
        break
        ;;
      [nN]*)
        answer=N
        break
        ;;
      '')
        answer=$default
        # print "$default"
        break
        ;;
      *) # Unrecognized input, ask again
        log_warn "Invalid anwser, please retry" "($choices) " ""
        ;;
    esac

  done

  case $answer in
    Y)
      log "› Yes"
      return 0
      ;;
    N|n)
      log "› No"
      return 1
      ;;
    *)
      log_error "Invalid answer" "$answer"
      return 2
      ;;
  esac
}

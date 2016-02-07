#!/usr/bin/env bash

# prompt.sh

import "lib/log"

# Wait for line input
# Uses readline option (-r)
prompt() {
  local question=$1
  local answer_default=${2-}
  local answer_pattern=${3-}
  local answer

  if [[ $ENV_BASH_VERSION -ge 4 ]] && [[ -n "$answer_default" ]]; then
    # Read with -i if bash > 4
    log_ask "$question" "" >&2
    read -e -r -i "$answer_default" answer

    [[ -n "$answer" ]] || (prompt "$@" && return)
  else
    # Show default value after the question if bash < 4
    local display_default=
    [[ -n "$answer_default" ]] && display_default="(default: $answer_default)"
    log_ask "$question" "$display_default" >&2
    read -e -r answer

    [[ -n "$answer" ]] || answer=$answer_default
  fi

  # If the is a pattern to valid the answer, and it does not match, ask again
  if [[ -n "$answer_pattern" ]] && ! [[ $answer =~ [(${answer_pattern})*] ]]; then
    # log_debug "Answer pattern" "$answer_pattern" >&2
    log_warn "Invalid anwser, please retry" "($answer_pattern) $answer" >&2
    prompt "$@" && return
  fi

  printf "%s" "$answer"
  return
}

# Wait for inline character input
# (-n 1)
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

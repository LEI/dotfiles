#!/usr/bin/env bash

# prompt.sh

import "lib/log"

prompt() {
    local question=$1

    log_ask "$question" "?" >&2
    read -e -r answer

    [ -n "$answer" ] || (prompt "$@" && return)

    echo "$answer"
    return
}

ask() {
    local question=$1
    local text=${2-}
    local default=${3-N}

    case $default in
        Y) choices="Y/n" ;;
        N) choices="y/N" ;;
        *) choices="y/n" ;;
    esac

    log_ask "$question" "$text($choices) " ""

    while true; do

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
            log "> Yes"
            return 0
            ;;
        N|n)
            log "> No"
            return 1
            ;;
        *)
            log_error "Invalid answer" "$answer"
            return 2
    esac
}

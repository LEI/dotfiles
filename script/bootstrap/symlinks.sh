#!/usr/bin/env bash

# bootstrap.sh

# github.com/holman/dotfiles/blob/master/script/bootstrap

import "lib/prompt"
import "lib/file"

bootstrap_symlinks_list() {
  printf "%s\n" "${DOT_FILES[@]}"
}

bootstrap_symlinks_build() {
  local file=$1 # Source
  local target=$2 # Destination
  # [[ -e "$file" ]] || log_warn "No such file or directory" "$file"
  local file_type=
  local file_prompt=
  local file_link=
  local overwrite= backup= ignore=

  file_type=$(typeof_file "$target")
  case $file_type in
    '')
      # log_success "Empty" "$target"
      # Target file does not exists, do not ignore, do not prompt
      file_prompt=false
      ;;
    link)
      if [[ ! -e "$target" ]]; then
        # log_error "Broken link" "$target"
        file_prompt="${red}Broken symbolic link ${white}${target}"
      else
        file_prompt="${yellow}Existing symbolic link ${white}${file_link}"
        # file_link=$(readlink $target)
        # if [[ "$file_link" = "$src" ]]; then
        #   # log_success "Already linked" "$target"
        #   ignore=true
        # else
        #   # log_warn "Existing link!" "$file_link -> $target"
        # fi
      fi
      ;;
    file|directory)
      # log_warn "Existing $file_type" "$target"
      file_prompt="${orange}Existing ${file_type} ${white}${target}"
      ;;
    *)
      # Unrecognized file type
      log_error "$file is a $file_type?!"
      ignore=true
      ;;
  esac

  # Not excluded, prompt may be needed
  if [[ "$ignore" != true ]] && [[ -n "$file_prompt" ]]; then
    if [[ "$file_prompt" != false ]]; then
      while true; do # wait for a valid reply
        # If prompt is not false, then ask the user to select an action
        local action=$(prompt \
  "${reset}${file_prompt}${reset}, what do you want to do?\n\
  › [${white}s${reset}]kip, [${white}o${reset}]verwrite, [${white}b${reset}]ackup" \
        "skip" "s|o|b")
        # [s]kip, [S]kip all, [o]verwrite, [O]verwrite all, [b]ackup, [B]ackup all
        # default?
        case $action in
          s*)
            log_debug "ACTION: Skip" "$target"
            overwrite=false
            backup=false
            ignore=true
            break
            ;;
          o*)
            log_debug "ACTION: Overwrite" "$target"
            overwrite=true
            backup=false
            ignore=false
            break
            ;;
          b*)
            log_debug "ACTION: Backup" "$target"
            overwrite=false
            backup=true
            ignore=false
            break
            ;;
          *)
            # Should be handled by the third agument of prompt()
            die "Invalid answer $action"
            ;;
        esac
      done # action is ready
    else # if prompt is set to false, the target should be clear
      overwrite=false
      backup=false
      ignore=false
    fi

    if [[ "$backup" = true ]]; then
      # Backup
      dry_run "mv $target.bak" || return 1

      log_info "Backuped $target" "$target.bak"
    elif [[ "$overwrite" = true ]]; then
      # Overwrite
      dry_run "rm $target" || return 1
      log_info "Removed $target"
    fi

    if [[ "$ignore" = false ]]; then
      # Link
      dry_run "ln -s $file $target"
      log_success "Symlinked $target" "$file"
    else
      log_info "Skipped" "$target"
    fi

  else
    log_info "Ignored" "$target"
  fi
}

bootstrap_symlinks() {
  local src dst
  local prefix="."
  local paths file

  # Parse paths expressions (src:dst)
  for paths in ${DOT_FILES[@]}; do

    if [[ "$paths" =~ [*:*] ]]; then
      # Path specified
      src=${paths%:*}
      dst=${paths#*:}
      [[ -z "$dst" ]] && dst=$src
      #   for path in ${src[@]}; do
      #     log_info "$path ->" "~/.${path#*/}"
      #   done
    else
      # Link to home and add prefix
      src="$paths"
      dst="${prefix}${paths#*/}"
    fi

    # Build absolute paths
    src="$DOT_ROOT/$src"
    dst="$DOT_TARGET/$dst"

    # Loop on each destination file
    for file in $(find_files "$src" "*.template"); do
      local file_name=${file##*/}
      local target
      local src_link

      # Handle pattern src/*:dst
      if [[ ! -d "$file" ]] && [[ -d "$dst" ]]; then
        if confirm "Link ${file#$DOT_ROOT/}" "${dst%\/}/${file_name}" Y; then
          target="${dst%\/}/${file_name}"
        else
          continue
        fi
      else
        target="$dst"
      fi

      src_link=$(readlink $dst) # Works on OS X
      [[ "$src_link" == "$src" ]] && log_success "Already linked" "$dst" && continue

      bootstrap_symlinks_build "$file" "$target"
    # End of destination files loop
    done
  # End of paths list loop
  done
}

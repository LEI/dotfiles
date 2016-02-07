#!/usr/bin/env bash

# bootstrap.sh

# github.com/holman/dotfiles/blob/master/script/bootstrap

import "lib/prompt"
import "lib/file"

bootstrap() {
  # log_debug "FILES =>" "${DOT_FILES[*]}"
  log_debug "Dry run" "$DRY_RUN"

  template_files
  symlink_files
}

template_files() {
  local file
  # Gather variable names for sed
  local vars=("${!DOT_USER_*}")
  # Look for each file ending with '.template' except .dotrc
  local templates=$(find $DOT_ROOT -name *.template ! -path $DOT_RC_TEMPLATE)

  for template in ${templates[@]}; do
    # Extract actual path
    file=${template%.template}

    # Confirm processing if target file exists
    if [[ -f "$file" ]]; then
      confirm "Overwrite ${file/$DOT_ROOT\//}" "$template" Y || continue
    fi

    # Fill file
    sed_file "$file" "$template" "${vars[@]}" || die "Could not sed file"
    log_success "Template processed" "${file/$DOT_ROOT\/}"
  done
}

symlink_files() {
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
      # [[ -e "$file" ]] || log_warn "No such file or directory" "$file"
      local out= # destination
      local file_name=${file##*/}
      local file_type=
      local file_prompt=
      local file_link=
      local overwrite= backup= ignore=

      # Handle patern src/*:dst
      if [[ ! -d "$file" ]] && [[ -d "$dst" ]]; then
        if confirm "Link ${file#$DOT_ROOT/}" "${dst%\/}/${file_name}" Y; then
          out="${dst%\/}/${file_name}"
        else
          continue
        fi
      else
        out="$dst"
      fi

      file_type=$(typeof_file "$out")
      case $file_type in
        '')
          # log_success "Empty" "$out"
          # Target file does not exists, do not ignore, do not prompt
          file_prompt=false
          ;;
        link)
          if [[ ! -e "$out" ]]; then
            # log_error "Broken link" "$out"
            file_prompt="${red}Broken symbolic link ${white}${out}"
          else
            # Portability?
            file_link=$(readlink $out)

            if [[ "$file_link" = "$src" ]]; then
              # log_success "Already linked" "$out"
              ignore=true
            else
              # log_warn "Existing link!" "$file_link -> $out"
              file_prompt="${yellow}Existing symbolic link ${white}${file_link}"
            fi
          fi
          ;;
        file|directory)
          # log_warn "Existing $file_type" "$out"
          file_prompt="${orange}Existing ${file_type} ${white}${out}"
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
  › [${white}s${reset}]kip, [${white}o${reset}]verwrite, [${white}b${reset}]ackup${white}" \
            "skip" "s|o|b")
            # [s]kip, [S]kip all, [o]verwrite, [O]verwrite all, [b]ackup, [B]ackup all
            # default?
            case $action in
              s*)
                log_debug "ACTION: Skip" "$out"
                overwrite=false
                backup=false
                ignore=true
                break
                ;;
              o*)
                log_debug "ACTION: Overwrite" "$out"
                overwrite=true
                backup=false
                ignore=false
                break
                ;;
              b*)
                log_debug "ACTION: Backup" "$out"
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
          dry_run "mv $out.bak" || return 1

          log_info "Backuped $out" "$out.bak"
        elif [[ "$overwrite" = true ]]; then
          # Overwrite
          dry_run "rm $out" || return 1
          log_info "Removed $out"
        fi

        if [[ "$ignore" = false ]]; then
          # Link
          dry_run "ln -s $file $out"
          log_success "Symlinked $out" "$file"
        else
          log_info "Skipped" "$out"
        fi

      else
        log_info "Ignored" "$out"
      fi

    # End of destination files loop
    done
  # End of paths list loop
  done
}

bootstrap

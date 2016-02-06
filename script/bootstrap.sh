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
    for file in $(find_files "$src"); do
      local overwrite= backup= ignore=
      # [[ -e "$file" ]] || log_warn "No such file or directory" "$file"
      local file_name=${file##*/}
      local file_type=
      local file_prompt=
      local file_link=

      # Handle patern src/*:dst
      if [[ ! -d "$file" ]] && [[ -d "$dst" ]]; then
				if confirm "Link ${file#$DOT_ROOT/}" "${dst%\/}/${file_name}" Y; then
        	dst="${dst%\/}/${file_name}"
				else
					continue
				fi
      fi

      file_type=$(typeof_file "$dst")
      case $file_type in
        '')
          # log_success "Empty" "$dst"
          file_prompt=false
          ;;
        link)
          if [[ ! -e "$dst" ]]; then
            # log_error "Broken link" "$dst"
            file_prompt="${red}Broken symbolic link ${white}${dst}"
          else
            # Portability?
            file_link=$(readlink $dst)

            if [[ "$file_link" = "$src" ]]; then
              # log_success "Already linked" "$dst"
              ignore=true
            else
              # log_warn "Existing link!" "$file_link -> $dst"
              file_prompt="${yellow}Existing symbolic link ${white}${file_link}"
            fi
          fi
          ;;
        file|directory)
          # log_warn "Existing $file_type" "$dst"
          file_prompt="${orange}Existing ${file_type} ${white}${dst}"
          ;;
        *)
          log_error "$file is a $file_type?!"
          ignore=true
          ;;
      esac

      if [[ "$ignore" != true ]] && [[ -n "$file_prompt" ]]; then

        if [[ "$file_prompt" != false ]]; then
          # Wait for a valid reply
          while true; do
            local action=$(prompt "${reset}${file_prompt}${reset}, what do you want to do?\n\
  › [${white}s${reset}]kip, [${white}o${reset}]verwrite, [${white}b${reset}]ackup${white}" "" "s*|o*|b*")
            # [s]kip, [S]kip all, [o]verwrite, [O]verwrite all, [b]ackup, [B]ackup all
            # default?
            case $action in
              s*)
                log_info "Skip" #"$dst"
                overwrite=false
                backup=false
                ignore=true
                break
                ;;
              o*)
                log_warn "Overwrite" #"$dst"
                overwrite=true
                backup=false
                ignore=false
                break
                ;;
              b*)
                log_success "Backup" #"$dst"
                overwrite=false
                backup=true
                ignore=false
                break
                ;;
              *)
                log_warn "Invalid answer, please retry" "[sob]"
            esac
          done # action is ready
        fi

        if [[ "$backup" = true ]]; then
          # Backup
          dry_run "$ mv $dst.bak" || return 1
        elif [[ "$overwrite" = true ]]; then
          # Overwrite
          dry_run "$ rm $dst" || return 1
        fi

        if [[ "$ignore" != true ]]; then
          # Link
          dry_run "$ ln -s $file $dst"
        fi

      else
        log_info "Skipped" "$dst"
      fi

    # End of destination files loop
    done
  # End of paths list loop
  done
  die "done"
}

bootstrap

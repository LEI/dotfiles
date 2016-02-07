#!/usr/bin/env bash

# bootstrap.sh

# github.com/holman/dotfiles/blob/master/script/bootstrap

import "lib/prompt"
import "lib/file"

bootstrap_symlinks() {
  # [[ $# -le 1 ]] || die "Missing argument: method"
  local method=${1-build}

  bootstrap_symlinks_parse $method ${DOT_FILES[@]}
}

bootstrap_symlinks_parse() {
  local method=$1; shift
  local expressions="$@"
  local p="."
  local expr file

  # Parse paths expressions (src:dst)
  for expr in ${expressions[@]}; do
    local src= dst= prefix="$p"

    local regexp="(.*):(.*)"

    if [[ "$expr" =~ $regexp ]]; then
      # Path specified
      src=${expr%:*}
      dst=${expr#*:}
      [[ -z "$dst" ]] && dst=$src
      prefix= # No prefix

      #   for path in ${src[@]}; do
      #     log_info "$path ->" "~/.${path#*/}"
      #   done
    else # No ':' found in expr
      # Link to home and (with prefix)
      src=${expr}
      # prefix=$p
      # dst=${prefix} #${expr#*/}
      # dst=${dst%\*}
    fi

    # Build absolute paths
    src="$DOT_ROOT/$src"
    dst="$DOT_TARGET/$dst"


    # Loop on each destination file
    # for file in $(find_files "$src" "*.template"); do
    # find "$src" -prune ! -name *.template -exec $cmd {} "$dst" \;
    while IFS= read -u 3 -rd '' file; do
      local target=${dst}
      local file_name=${file##*/}
      local file_link=

      # Handle pattern src/*:dst
      if [[ -d "$target" ]]; then
        # Add prefix if needed and append file name to the target directory
        target="${target%\/}/${prefix}${file_name}"

        # Confirm creation
        # [[ "$method" == "build" ]] && \
        #   confirm "Link ${file#$DOT_ROOT/}" "${target}" Y || \
        #   continue
      else
        log_debug "Pristine target" "$target"
      fi

      # if [[ ! -e "$dst" ]] && [[ -d "$file" ]]; then
      #   [[ "$method" == "list" ]] && \
      #     confirm "Create directory ${dst}" "${file}" Y && \
      #     dry_run "mk d $dst" || \
      #     continue
      # if [[ ! -d "$file" ]] && [[ -d "$dst" ]]; then
      #   [[ "$method" == "build" ]] && \
      #     confirm "Link ${file#$DOT_ROOT/}" "${dst%\/}/${file_name}" Y || \
      #     continue
      #   target="${dst%\/}/${p}${file_name}"
      # else
      #   target="${dst}"
      # fi
      # elif [[ -d "$file" ]]; then
      #   target="${dst}/"
      # else
      #   log_info "Unhandled target: $dst"
      # fi
      #
      # file_link=$(readlink $target || echo false) # Works on OS X
      # [[ "$file_link" == "$src" ]] && log_success "Already linked" "$target" && continue

      bootstrap_symlinks_$method "$file" "$target"
    done 3< <(find $src -name '*.template' -o -depth 0 -print0)
    # done 3< <(find $src -name '*.template' -o \( -type d -depth 0 -o -type f -depth 0 \) -print0)

  done
}

bootstrap_symlinks_build() {
  local file=$1 # Source
  local target=$2 # Destination
  # [[ -e "$file" ]] || log_warn "No such file or directory" "$file"
  local file_type=
  local file_prompt=
  local default= overwrite= backup= ignore=

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
        default="overwrite"
      else
        local file_link=$(readlink $target || echo false) # Works on OS X
        # log_debug "$file_link == $file"
        if [[ "$file_link" == "$file" ]]; then
          log_success "Already linked" "$target"
          ignore=true
        else
          file_prompt="${yellow}Existing symbolic link ${white}${file_link}"
        fi
      fi
      ;;
    file|directory)
      # log_warn "Existing $file_type" "$target"
      file_prompt="${orange}Existing ${file_type} ${white}${target}"
      default
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
        "${default-skip}" "s|o|b")
        # [s]kip, [S]kip all, [o]verwrite, [O]verwrite all, [b]ackup, [B]ackup all
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

bootstrap_symlinks_list() {
  local file=$1 # Source
  local target=$2 # Destination
  printf "%s\n" "$file -> $target"
}

#!/usr/bin/env bash

# bootstrap.sh

# github.com/holman/dotfiles/blob/master/script/bootstrap

import "lib/prompt"
import "lib/file"

bootstrap_symlinks() {
  local method="build"

  case $1 in
    list|build)
      method=$1
      ;;
    *)
      die "Unknown method: $1"
      ;;
  esac

  # Prefix (DOT_CONFIG_PREFIX) and paths must be defined in .dotrc
  # Each path  must follow the pattern src[:dst]
  bootstrap_symlinks_foreach $method ${DOT_SYMLINK[@]}
}

bootstrap_symlinks_foreach() {
  local prefix=$DOT_CONFIG_PREFIX
  local method=$1; shift
  local expressions="$@"
  local expr file

  # Parse paths expressions (src:dst)
  for expr in ${expressions[@]}; do
    local src=
    local dst=
    local regexp="(.*):(.*)"
    # local prefix=$p

    if [[ "$expr" =~ $regexp ]]; then
      # Path specified
      src=${expr%:*}
      dst=${expr#*:}
      [[ -z "$dst" ]] && dst=${src%\/\*} # Normalize destination
    else # No ':' found in expr
      # Link to home and (with prefix)
      src=${expr}
      dst= #${prefix}
    fi

    #log_debug "find $DOT_ROOT/$src"

    # Loop on each destination file
    while IFS= read -u 3 -rd '' file; do
      # local file_rel=${file#$DOT_ROOT/}
      local file_name=${file##*/}
      local target=

      if [[ -n "$dst" ]]; then
        target="$dst"
        [[ "$src" =~ [*\*$] ]] && target+="/${file_name}"
      else
        target="${prefix}${file_name}"
      fi

      # Build absolute destination
      bootstrap_symlinks_$method "$file" "$DOT_TARGET/$target"
    done 3< <(find $DOT_ROOT/$src -depth 0 ! -name '*.template' -print0)
    #-name '*.template' -o -depth 0 -print0) # End while
    # \( -type d -depth 0 -o -type f -depth 0 \)

  done
}

bootstrap_symlinks_list() {
  local file=$1 # Source
  local target=$2 # Destination
  #printf "%s\n" "$file -> $target"
  log_info "${file#$DOT_ROOT/} ->" "$target"
}

bootstrap_symlinks_build() {
  local file=$1 # Source
  local target=$2 # Destination
  # [[ -e "$file" ]] || log_warn "No such file or directory" "$file"
  local file_type=
  local file_prompt=
  local default= overwrite= backup= ignore=

  local target_dir="$(dirname $target)"
  # Check target directory
  if [[ ! -e "$target_dir" ]]; then
    make_dir "$target_dir" && log_info "Created" "$target_dir" #|| return 1
  fi

  file_type=$(type_of "$target")
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
        local file_link=$(readlink_file $target) # Works on OS X
        # log_debug "$file_link == $file"
        if [[ "$file_link" == "$file" ]]; then
          # log_success "Already linked" "$target"
          ignore=true
        else
          file_prompt="${yellow}Existing symbolic link ${white}${file_link}"
        fi
      fi
      ;;
    file|directory)
      # log_warn "Existing $file_type" "$target"
      file_prompt="${red}Existing ${file_type} ${white}${target}"
      default="backup"
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
            # log_debug "ACTION: Skip" "$target"
            overwrite=false
            backup=false
            ignore=true
            break
            ;;
          o*)
            # log_debug "ACTION: Overwrite" "$target"
            overwrite=true
            backup=false
            ignore=false
            break
            ;;
          b*)
            # log_debug "ACTION: Backup" "$target"
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
      backup_file "$target" && log_info "Saved" "$target.bak" || return 1
    elif [[ "$overwrite" = true ]]; then
      # Overwrite
      remove_file "$target" && log_info "Removed" "$target" || return 1
    fi

    if [[ "$ignore" = false ]]; then
      # Link
      link_file "$file" "$target" && log_success "Symlinked" "$target" || return 1
    else
      log_info "Skipped" "$target"
    fi

    log_debug "-> $?"
    if [[ $? -gt 0 ]]; then
      log_error "Errored with status $?"
    fi

  else
    log "Ignored" "$target"
  fi
}












# _bootstrap_symlinks_parse() {
#   local prefix=$DOT_CONFIG_PREFIX
#   local method=$1; shift
#   local expressions="$@"
#   local expr file
#
#   # Parse paths expressions (src:dst)
#   for expr in ${expressions[@]}; do
#     local src=
#     local dst=
#     local regexp="(.*):(.*)"
#     local p=$prefix
#     # local prefix=$p
#
#     if [[ "$expr" =~ $regexp ]]; then
#       # Path specified
#       src=${expr%:*}
#       dst=${expr#*:}
#       [[ -z "$dst" ]] && dst=$src
#
#       # src=${DOT_ROOT}/${src}
#       # dst=${DOT_TARGET}/${dst}
#       p="" # No prefix
#
#       #   for path in ${src[@]}; do
#       #     log_info "$path ->" "~/.${path#*/}"
#       #   done
#     else # No ':' found in expr
#       # Link to home and (with prefix)
#       src=${expr}
#       dst=
#       # dst=${prefix}
#
#       # dst=${expr}
#       # dst="${dst%\/}/${prefix}${file_name}"
#
#       # prefix=$p
#       # dst=${prefix} #${expr#*/}
#       # dst=${dst%\*}
#     fi
#
#     # Build absolute paths
#     src="$DOT_ROOT/$src"
#     dst="$DOT_TARGET/$dst"
#
#
#     # Loop on each destination file
#     # for file in $(find_files "$src" "*.template"); do
#     # find "$src" -prune ! -name *.template -exec $cmd {} "$dst" \;
#     while IFS= read -u 3 -rd '' file; do
#       # local prefix=${prefix}
#       local file_name=${file##*/}
#       local target=${dst%\*} # Remove trailing '/*'
#       # target+=${file_name}
#       echo "$target == $DOT_TARGET ]]; then $target/$file_name"
#       # [[ "$has_prefix" = true ]] && target+=$prefix
#       if [[ -f "$file" ]] && [[ "$target" == "$DOT_TARGET/" ]]; then
#         # log_debug "F $target -> adding $file_name" #"$src $dst"
#         # [[ "$has_prefix" != true ]] && target+="/"
#         target+="${p}${file_name}"
#         # log_debug "= $target" "<<<<<<<<<<<<<<<<<"
#       elif [[ -f "$file" ]]; then
#         target+="/${p}${file_name}"
#         log_debug "F $file"
#       elif [[ -d "$file" ]]; then
#         log_debug "D $target -> triming /?!" #"$src $dst"
#         # target="${target%\/}"
#       else
#         log_warn "todo $target"
#       fi
#       printf "%s\n" "$file > $target" && break
#       # local file_link=
#
#       # Handle pattern src/*:dst
#       # if [[ -d "$target" ]]; then
#
#         # Add prefix if needed and append file name to the target directory
#         # target="${target%\/}/${prefix}${file_name}"
#
#         # Confirm creation
#         # [[ "$method" == "build" ]] && \
#         #   confirm "Link ${file#$DOT_ROOT/}" "${target}" Y || \
#         #   continue
#       # else
#         log_debug "target => $target" "$src"
#       # fi
#
#       # if [[ ! -e "$dst" ]] && [[ -d "$file" ]]; then
#       #   [[ "$method" == "list" ]] && \
#       #     confirm "Create directory ${dst}" "${file}" Y && \
#       #     dry_run "mk d $dst" || \
#       #     continue
#       # if [[ ! -d "$file" ]] && [[ -d "$dst" ]]; then
#       #   [[ "$method" == "build" ]] && \
#       #     confirm "Link ${file#$DOT_ROOT/}" "${dst%\/}/${file_name}" Y || \
#       #     continue
#       #   target="${dst%\/}/${p}${file_name}"
#       # else
#       #   target="${dst}"
#       # fi
#       # elif [[ -d "$file" ]]; then
#       #   target="${dst}/"
#       # else
#       #   log_info "Unhandled target: $dst"
#       # fi
#       #
#       # file_link=$(readlink $target || echo false) # Works on OS X
#       # [[ "$file_link" == "$src" ]] && log_success "Already linked" "$target" && continue
#
#       bootstrap_symlinks_$method "$file" "$target"
#     done 3< <(find $src -name '*.template' -o -depth 0 -print0) # End while
#     # done 3< <(find $src -name '*.template' -o \( -type d -depth 0 -o -type f -depth 0 \) -print0)
#
#   done
# }

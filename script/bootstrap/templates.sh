#!/usr/bin/env bash

# templates.sh

# github.com/holman/dotfiles/blob/master/script/bootstrap

import "lib/prompt"
import "lib/file"

bootstrap_templates() {
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

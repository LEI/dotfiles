# #!/usr/bin/env bash

# init.sh

init_platform() {
  local platform=$(echo "$UNAME" | to_lower_case)
  local platform_root="${DOT_INIT}/${platform}"
  local platform_file=

  [[ -d "$platform_root" ]] || {
    log_error "No init directory for $UNAME" "$platform_root not found"
    return 1
  }

  case $UNAME in
    Darwin) # OS X Defaults
      platform_file="$platform_root/defaults.sh"

      [[ -f "$platform_file" ]] || {
        log_error "No defaults for $UNAME" "$platform_file not found"
        return 1
      }

      [[ "$(whoami)" != "root" ]] && log_warn "Root access will be required"

      # Uses the hostname as a placeholder
      local name=$(prompt "Computer name" "$(hostname)")
      if [[ -n "$name" ]]; then
        COMPUTER_NAME=$name
      fi

      if confirm "Disable Notification Center" "" N; then
        OSX_DISABLE_NOTIFICATION_CENTER=true
      fi

      if confirm "Disable 'natural' scrolling" "" N; then
        OSX_DISABLE_NATURAL_SCROLLING=true
      fi

      if confirm "Apply SSD specific tweaks" "" N; then
        OSX_SSD_TWEAKS=true
      fi

      # Source init file
      if source $platform_file; then
        log_info "Some changes require a logout/restart to take effect"
      else
        log_error "Could not source" "$platform_file"
      fi


      # TODO: Handle multiple files
      # Currently only the last file *.terminal is used
      local theme_path
      local theme_name
      local f
      for f in $(find $platform_root -name *.terminal); do
        f="${f%.terminal}"
        theme_name="${f##*/}"
        theme_path="${f%/*}"
      done

      # Set the theme in Terminal.app
      # TODO: applescript -> .scpt
      if [[ -n "$theme_path-" ]] && [[ -n "$theme_name" ]] && \
        [[ -f "${theme_path}/${theme_name}.terminal" ]]; then
        if confirm "Use $theme_name theme in Terminal.app" "" N; then
          local terminal_osascript="$platform_root/osascript/terminal.scpt"
          if [[ -f "$terminal_osascript" ]]; then
            log_info "TODO: execute apple script" "$terminal_osascript"
          else
            log_warn "Could not execute apple script" "$terminal_osascript"
          fi
        fi
      else
        log_error "Terminal theme not found" "$platform_root/*.terminal"
      fi

      # Kill affected applications
      if confirm "Kill affected applications" "" N; then
        for app in "Activity Monitor" "Address Book" "Calendar" "Contacts" "cfprefsd" \
          "Dock" "Finder" "Google Chrome" "Google Chrome Canary" "Mail" "Messages" \
          "Opera" "Photos" "Safari" "SizeUp" "Spectacle" "SystemUIServer" "Terminal" \
          "Transmission" "Tweetbot" "Twitter" "iCal"; do
          killall "${app}" &> /dev/null
        done
      fi
      ;;
    *)
      log_warn "No init script" "$UNAME"
      return 0
      ;;
  esac
}

# #!/usr/bin/env bash

# # platform.sh

platform_defaults() {
  local platform=$(echo "$UNAME" | to_lower_case)
  local platform_root="$DOT_ROOT/platform/$platform"
  local platform_file=

  [[ -d "$platform_root" ]] || {
    log_error "No defaults for $UNAME" "$platform_root not found"
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

      # TODO: Handle multiple files
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
osascript <<EOD

tell application "Terminal"

  local allOpenedWindows
  local initialOpenedWindows
  local windowID
  set themeName to "$theme_name"

  (* Store the IDs of all the open terminal windows. *)
  set initialOpenedWindows to id of every window

  (* Open the custom theme so that it gets added to the list
     of available terminal themes (note: this will open two
     additional terminal windows). *)
  do shell script "open '$theme_path" & themeName & ".terminal'"

  (* Wait a little bit to ensure that the custom theme is added. *)
  delay 1

  (* Set the custom theme as the default terminal theme. *)
  set default settings to settings set themeName

  (* Get the IDs of all the currently opened terminal windows. *)
  set allOpenedWindows to id of every window

  repeat with windowID in allOpenedWindows

    (* Close the additional windows that were opened in order
       to add the custom theme to the list of terminal themes. *)
    if initialOpenedWindows does not contain windowID then
      close (every window whose id is windowID)

    (* Change the theme for the initial opened terminal windows
       to remove the need to close them in order for the custom
       theme to be applied. *)
    else
      set current settings of tabs of (every window whose id is windowID) to settings set themeName
    end if

  end repeat

end tell

EOD
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
      log_warn "No defaults" "$UNAME"
      return 0
      ;;
  esac

  if source $platform_file; then
    log_info "Some changes require a logout/restart to take effect"
  else
    log_error "Could not source" "$platform_file"
  fi
}

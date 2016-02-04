# #!/usr/bin/env bash
#
# # defaults.sh

platform_defaults() {
	local platform_file="$DOT_SCRIPT/platform/${UNAME}.sh"

    if [[ -f "$platform_file" ]]; then

		case $UNAME in
			darwin) # OSX
				TERMINAL_THEME="Solarized"
				TERMINAL_THEME_PATH="$DOT_ROOT/themes/$TERMINAL_THEME.terminal"
				if [[ -f "$TERMINAL_THEME_PATH" ]] && \
					confirm "Use $TERMINAL_THEME theme in Terminal" "$TERMINAL_THEME_PATH" N; then
					OSX_TERMINAL_THEME="$TERMINAL_THEME"
				else
					log_error "Terminal theme not found" "$TERMINAL_THEME_PATH"
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

				# if confirm "Kill affected applications" "Terminal will be closed!" N; then
				# 	OSX_KILL_APPS=true
				# fi

				[[ "$(whoami)" != "root" ]] && \
					log_warn "Root access is required"
				;;
		esac

		if source $platform_file; then
			log_info "Some changes require a logout/restart to take effect"
		else
			log_error "Could not source" "$platform_file"
		fi
    else
        log_error "Defaults file not found" "$platform_file"
    fi
}

platform_defaults

# #!/usr/bin/env bash
#
# # defaults.sh

defaults() {
	local platform_defaults="$DOT_SCRIPT/platform/${UNAME}.sh"

    if [[ -f "$platform_defaults" ]]; then
        source $platform_defaults
    else
        log_error "Defaults file not found" "$platform_defaults"
    fi
}

defaults

# #!/usr/bin/env bash
#
# # defaults.sh

defaults() {
	local os_defaults="$DOT_ROOT/os/${UNAME}.sh"

    if [[ -f "$os_defaults" ]]; then
        source $os_defaults
    else
        warn "Defaults file not found" "$os_defaults"
    fi
}

defaults

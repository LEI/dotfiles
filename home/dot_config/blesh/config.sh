# https://github.com/akinomyoga/ble.sh/blob/master/blerc.template

# bleopt color_scheme=base16 # or default
bleopt color_scheme=catppuccin_mocha

# https://github.com/akinomyoga/ble.sh#22-disable-features

# # Disable syntax highlighting
# bleopt highlight_syntax=

# # Disable highlighting based on filenames
# bleopt highlight_filename=

# # Disable highlighting based on variable types
# bleopt highlight_variable=

# Disable auto-complete (Note: auto-complete is enabled by default in bash-4.0+)
bleopt complete_auto_complete=
# bleopt complete_auto_delay=300

# Disable auto-complete based on the command history
bleopt complete_auto_history=

# Disable ambiguous completion
bleopt complete_ambiguous=

# Disable menu-complete by TAB
bleopt complete_menu_complete=

# Disable menu filtering (Note: auto-complete is enabled by default in bash-4.0+)
bleopt complete_menu_filter=

# Disable EOF marker like "[ble: EOF]"
bleopt prompt_eol_mark=''
# bleopt prompt_eol_mark='⏎'

# Disable error exit marker like "[ble: exit %d]"
# bleopt exec_errexit_mark=
bleopt exec_errexit_mark=$'\e[91m[error %d]\e[m'

# Disable elapsed-time marker like "[ble: elapsed 1.203s (CPU 0.4%)]"
# bleopt exec_elapsed_mark=
# bleopt exec_elapsed_mark=$'\e[94m[%ss (%s %%)]\e[m'
# bleopt exec_elapsed_enabled='sys+usr>=10*60*1000' # e.g. ten minutes for total CPU usage

# Disable exit marker like "[ble: exit]"
bleopt exec_exit_mark=

# Disable some other markers like "[ble: ...]"
# bleopt edit_marker=
# bleopt edit_marker_error=

# bleopt history_erasedups_limit=100
bleopt history_share=1

# {{- if lookPath "fzf" | isExecutable }}
# Note: If you want to combine fzf-completion with bash_completion, you need to
# load bash_completion earlier than fzf-completion.  This is required
# regardless of whether to use ble.sh or not.
# See https://github.com/akinomyoga/ble.sh#fzf-integration
# if [ -f /etc/profile.d/bash_completion.sh ]; then
#   source /etc/profile.d/bash_completion.sh
# fi

# ble-import -d integration/fzf-completion
# ble-import -d integration/fzf-key-bindings
# {{- end }}

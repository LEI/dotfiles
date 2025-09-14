{{- /* chezmoi:modify-template */ -}}
{{- $prefix := "" -}}
{{- $suffix := "" -}}
{{- .chezmoi.stdin
  | replaceAllRegex "(tmux set -g message-style .*fg=).{THEME.background.}" "${1}${THEME[bblack]}"
  | replaceAllRegex "(tmux set -g message-command-style )\".*\"" "${1}\"\""
  | replaceAllRegex "(tmux set -g status-left .*fg=).{THEME.bblack.}" "${1}#{?client_prefix,${THEME[bblack]},${THEME[foreground]}}"
  | replaceAllRegex "(tmux set -g status-left .*bg=).{THEME.blue.}" "${1}#{?client_prefix,${THEME[blue]},default}"
  | replaceAllRegex "(tmux set -g window-status-current-format .*,).active_terminal_icon .window_space" "${1}"
  | replaceAllRegex "(tmux set -g window-status-format .*,).terminal_icon .window_space" "${1}"
  | replaceAllRegex "(tmux set -g window-status-current-format .*)#{.window_last_flag, , }" "${1}"
  | replaceAllRegex "(tmux set -g window-status-format .*)#.fg=.{THEME.yellow.}.#{.window_last_flag,.  , }" "${1}"
  | replaceAllRegex "(tmux set -g status-right \").*(.battery_status.*.date_and_time).*\"" (printf "${1}%s${2}%s\"" $prefix $suffix)
-}}

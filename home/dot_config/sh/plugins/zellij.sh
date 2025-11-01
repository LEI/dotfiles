# TODO: replace with carapace spec
if ! hash zel 2>/dev/null; then
  zel() {
    if [[ $# -ne 0 ]]; then
      zellij "$@"
    else
      zellij attach 0 || zellij --session 0
    fi
  }

  if hash _zellij 2>/dev/null; then
    complete -F _zellij zel
  fi
fi

# # https://github.com/zellij-org/zellij/discussions/2889
# # https://www.reddit.com/r/zellij/comments/10skez0/does_zellij_support_changing_tabs_name_according/
# zellij_tab_name_update() {
#   if [[ -z "$ZELLIJ" ]]; then
#     return
#   fi
#   local tab_name=
#   if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
#     tab_name+="$(basename "$(git rev-parse --show-toplevel)")/"
#     tab_name+="$(git rev-parse --show-prefix)"
#     tab_name="${tab_name%/}"
#   else
#     tab_name="$PWD"
#     if [[ "$tab_name" == "$HOME" ]]; then
#       tab_name="~"
#     else
#       tab_name="${tab_name##*/}"
#     fi
#   fi
#   command nohup zellij action rename-tab "$tab_name" >/dev/null 2>&1
# }

# zellij_tab_name_update
# chpwd_functions+=(zellij_tab_name_update)

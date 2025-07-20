# shellcheck disable=all
{{- /* chezmoi:modify-template */ -}}
{{- .chezmoi.stdin
  | replaceAllRegex "# shellcheck disable=all" ""
  | replaceAllRegex "== \"gitlab.com\"" "!= \"\""
-}}

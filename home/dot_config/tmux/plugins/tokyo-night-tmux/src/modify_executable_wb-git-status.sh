# shellcheck disable=all
{{- /* chezmoi:modify-template */ -}}
{{- .chezmoi.stdin
  | replaceAllRegex "# shellcheck disable=all" ""
  | replaceAllRegex "url \\| awk -F '@\\|:'" "url | sed -e 's/^ssh:\\/\\///' | awk -F '@|:|/'"
  | replaceAllRegex "== \"gitlab.com\"" "!= \"\""
-}}

{{- /* chezmoi:modify-template */ -}}
{{- .chezmoi.stdin
  | replaceAllRegex "url \\| awk -F '@\\|:'" "url | sed -e 's/^ssh:\\/\\///' | awk -F '@|:|/'"
  | replaceAllRegex "== \"gitlab.com\"" "!= \"\""
-}}

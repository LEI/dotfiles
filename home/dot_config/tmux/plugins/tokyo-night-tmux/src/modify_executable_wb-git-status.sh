{{- /* chezmoi:modify-template */ -}}
{{- .chezmoi.stdin | replaceAllRegex "== \"gitlab.com\"" "!= \"\"" -}}

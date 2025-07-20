# shellcheck disable=all
{{- /* chezmoi:modify-template */ -}}
{{- .chezmoi.stdin | replaceAllRegex "== \"gitlab.com\"" "!= \"\"" -}}

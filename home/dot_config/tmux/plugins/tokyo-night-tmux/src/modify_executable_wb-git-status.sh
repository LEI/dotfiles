{{- /* chezmoi:modify-template */ -}}
{{- $output := .chezmoi.stdin
  | replaceAllRegex "url \\| awk -F '@\\|:'" "url | sed -e 's/^ssh:\\/\\///' | awk -F '@|:|/'"
  | replaceAllRegex "== \"gitlab.com\"" "!= \"\""
-}}
{{- if lookPath "bkt" | isExecutable -}}
{{- $output = $output
  | replaceAllRegex "\\((gh|glab) " "(bkt --cwd --ttl=60m -- ${1} "
  | replaceAllRegex "\\(bkt (.*)?--ttl=\\w+ (.*)?(gh|glab) " "(bkt ${1}--ttl=60m ${2}${3} "
-}}
{{- else -}}
{{- $output = $output | replaceAllRegex "\\(bkt .* -- (gh|glab) " "(${1} " -}}
{{- end -}}
{{- $output -}}

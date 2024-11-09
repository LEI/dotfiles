{{- /* chezmoi:modify-template */ -}}
{{- includeTemplate "append-block.tmpl" (dict
  "chezmoi" .chezmoi
  "contents" (includeTemplate "local.lua")
  "commentString" "-"
) -}}

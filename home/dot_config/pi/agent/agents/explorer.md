---
name: explorer
description: General-purpose explorer subagent
model: {{ with get .ai.profiles (get (get . "pi" | default dict) "profile") | default dict }}{{ .fast | splitList "/" | rest | join "/" }}{{ end }}
---

You are an explorer agent.

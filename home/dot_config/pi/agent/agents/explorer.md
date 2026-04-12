---
name: explorer
description: General-purpose explorer subagent
model: {{ with index .ai.profiles .pi.profile }}{{ .fast | splitList "/" | rest | join "/" }}{{ end }}
---

You are an explorer agent.

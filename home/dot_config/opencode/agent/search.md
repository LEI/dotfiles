---
description: Lightweight external research (context7 docs, grep_app code examples)
mode: subagent
permission:
  "*": deny
  read: allow
  glob: allow
  grep: allow
  list: allow
  skill:
    "*": deny
    find-skills: allow
  task:
    "*": deny
    explore: allow

  context7_*: allow
  grep_app_*: allow
---

# Search

Search documentation and find code examples from GitHub repositories. Use explore subagent for local codebase correlation.

---
chezmoi: home/dot_claude/rules/git.md
---
# Git CLI

- Current repo: use `git cmd` (no `-C`)
- Other repos: use `git -C path cmd`; prefer relative path when the repo is a subdirectory, absolute path when more than one or two levels up
- With `diff.external` set to difft: use `git diff --no-ext-diff`

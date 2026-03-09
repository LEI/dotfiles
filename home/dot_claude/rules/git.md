---
chezmoi: home/dot_claude/rules/git.md
---

# Git CLI

- Current repo: use `git cmd` (no `-C`)
- Other repos: use `git -C path cmd`; prefer relative path when the repo is a subdirectory, absolute path when more than one or two levels up
- With `diff.external` set to difft: use `git diff --no-ext-diff`

## Branch naming

- Format: `type/short-description` (kebab-case, lowercase)
- Types mirror Conventional Commits: feat, fix, chore, docs, refactor, ci, test, perf
- Max ~50 characters total; description segment ~30 characters
- For projects with an issue system: `type/123-short-description`
- No snake_case, no camelCase

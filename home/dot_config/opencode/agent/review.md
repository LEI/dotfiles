---
# https://opencode.ai/docs/agents/#markdown
description: Comprehensive code review with best practices and security focus
mode: subagent
# model: anthropic/claude-sonnet-4-20250514
# temperature: 0.1
permission:
  "*": deny
  read: allow
  git_git_*: deny
  git_git_branch: allow
  git_git_diff*: allow
  git_git_log: allow
  git_git_show: allow
  git_git_status: allow
  skill:
    "*": deny
    code-review-excellence: allow
---

# Review

Follow the code-review-excellence skill workflow. Focus on code quality, security, performance, and maintainability. Provide actionable feedback without making direct changes.

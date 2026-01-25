---
description: Review changes, stage files and create commit messages
agent: build
---

# Commit

Analyze the changes and create a concise, descriptive commit message for each
change. Follow conventional commit format if appropriate.

Recent commit history:

!`git log --oneline -5`

Git status:

!`git status --branch --short`

Modified files:

!`git diff --stat`

Already staged files:

!`git diff --staged --stat`

Use the git and read tool to inspect files if needed.

Ask for confirmation before staging files and creating commits.

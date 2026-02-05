---
description: Review changes, stage files and create commit messages
agent: build
---

Atomic commits: one logical change per commit, buildable after each.
Match project style from history, else use conventional: `type(scope): why`
Subject: imperative, lowercase, no period, ≤50 chars. Body lines ≤72 chars.

!`git log --oneline -5`
!`git status -sb`
!`git diff --stat`
!`git diff --staged --stat`

Split unrelated changes into separate commits. Confirm before committing.

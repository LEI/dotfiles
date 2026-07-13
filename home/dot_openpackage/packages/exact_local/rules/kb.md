---
description: Knowledge base vaults location
---

# KB

Knowledge base vaults live at `~/kb/*`.
`~/kb` itself is not a git repo, it is a directory of per-vault symlinks.
Each vault dir such as `~/kb/personal` is its own git repo, usually a symlink into its real checkout.
Edit inside the vault repo but leave commits and pushes to the operator; never treat `~/kb` as a repo.

---
chezmoi: home/dot_claude/rules/style.md
---
# General style

- Avoid numbering in markdown (steps, headings): harder to maintain, use bullets instead
- Bullet separator: colon-space, not dashes
- Headings: sentence case (capitalize first word and proper nouns only)
- Punctuation: never use em dashes anywhere (in prose, comments, memory, or rules); use a comma, colon, or semicolon instead
- Tables: avoid in memory files and rules; use bullet lists unless columns are genuinely comparative and list form would be unreadable
- No emojis, horizontal rules, or decorative separators
- Keep lines short; no alignment padding
- Avoid banner/section comments; let class, method, and function names speak for themselves
- Comments: sentence case, no trailing dot for single sentences; concise and precise; only add when the logic is non-obvious; remove when they restate the function name or describe what the code plainly shows; never include dates, session context, or internal tool references in code comments
- Prefer clean fixes over workarounds: fix the root cause before adding lint/type-check ignore annotations
- Lists and arrays: alphabetical order preferred; one item per line unless the list is short enough to fit on one line without wrapping (respect linter formatting)
- References to issues, PRs, and MRs in markdown: `[title](url)` not bare `#N`

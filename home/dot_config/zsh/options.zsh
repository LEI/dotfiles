# Allow # for comments in interactive shells
setopt INTERACTIVE_COMMENTS

# Prevent file overwrite on stdout redirection (use >| to force)
setopt NO_CLOBBER

# Case-insensitive globbing
setopt NO_CASE_GLOB

# Include dotfiles in globbing and completion
setopt GLOB_DOTS

# Pass unmatched globs as literal strings instead of erroring
setopt NO_NOMATCH

# Expand unmatched globs to nothing (overrides NO_NOMATCH)
# setopt NULL_GLOB

# Move cursor into the word on completion, not just the end
setopt COMPLETE_IN_WORD

# Zsh 5.2+ options
autoload -Uz is-at-least
if is-at-least 5.2; then
  # Recursive globbing with ** (e.g. **/*.txt)
  setopt GLOB_STAR_SHORT
fi

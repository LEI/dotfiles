# Allow # for comments anywhere on the line
setopt INTERACTIVE_COMMENTS

# Don't save duplicate consecutive commands
setopt HIST_IGNORE_DUPS

# Keep more history, append on shell exit
setopt APPEND_HISTORY

# Share history between sessions
setopt SHARE_HISTORY

# Enable ** globbing for recursive paths
setopt GLOB_STAR_SHORT

# Unmatched globs expand to nothing instead of aborting
setopt NULL_GLOB

# Complete from anywhere in the word
setopt COMPLETE_IN_WORD

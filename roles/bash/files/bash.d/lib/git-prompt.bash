#
# Git prompt
#

require ~/.git_prompt

# PROMPT_COMMAND='__git_ps1 "\u at \h in \w" "\n\\\$ "'
# __git_ps1 " on %s" | sed -re "s/(\son\s)(\W*)(\w+)(\W*)/\1\2$red\3$white\4/"

# Colored hints (only when used with 2 arguments as prompt command)
GIT_PS1_SHOWCOLORHINTS=1

# * unstaged changes
# + staged changes
GIT_PS1_SHOWDIRTYSTATE=1

# $ stashed items
GIT_PS1_SHOWSTASHSTATE=1

# % untracked files
GIT_PS1_SHOWUNTRACKEDFILES=1

# Difference between HEAD and its upstream:
# <           behind
# >           ahead
# <>          diverged
# =           no difference
#   verbose     show number of commits ahead/behind (+/-) upstream
#   name        if verbose, then also show the upstream abbrev name
#   legacy      don't use the '--count' option available in recent
#               versions of git-rev-list
#   git         always compare HEAD to @{upstream}
#   svn         always compare HEAD to your SVN upstream
# GIT_PS1_SHOWUPSTREAM="auto"

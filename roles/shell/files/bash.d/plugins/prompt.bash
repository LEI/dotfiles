#
# Bash prompt
#
# https://github.com/necolas/dotfiles
# https://github.com/mathiasbynens/dotfiles/blob/master/.bash_prompt
# https://github.com/demure/dotfiles/blob/master/subbash/prompt

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

prompt_right() {
  local text=${1:-}
  local color=${2:-}
  local margin=${3:-0}
  local columns=

  if [[ -n "$COLUMNS" ]]; then
    columns="$COLUMNS"
  else
    columns=$(tput cols)
  fi

  if [[ -n "$color" ]]; then
    text="${color}${text}"
    margin=$((${margin} - ${#color}))
  fi

  printf "%*s" "$((${columns} - ${margin}))" "${text}"
}

prompt_command() {
  # Exit code
  local exit=$?

  # Default symbols
  local prompt_symbol="${PROMPT_SYMBOL:-$ }"
  local prompt_symbol_error="${PROMPT_SYMBOL_ERROR:-! }"

  # Colors
  local c_reset="\[${reset}\]"
  local c_text="\[${byellow}\]" # \[\e[2m\]
  local c_user="\[${blue}\]"
  local c_user_root="\[${red}\]"
  local c_host="\[${bblue}\]"
  local c_host_ssh="\[${bold}\]\[${red}\]"
  local c_cwd="\[${white}\]"
  local c_symbol="\[${white}\]"
  local c_symbol_error="\[${red}\]"
  local c_git_master="\[${yellow}\]"

  # Prompt format
  # local prefix_host="@" prefix_cwd=":" prefix_git="(" suffix_git=")"
  local prefix_host="${c_text} at ${c_reset}"
  local prefix_cwd="${c_text} in ${c_reset}"
  local prefix_git="${c_text} on ${c_reset}"
  local suffix_git=""

  # Start of the primary prompt
  local prompt='\n'

  # Terminal title to the current working directory
  prompt+='\[\033]0;\w\007\]'

  # Timestamp to the right
  local prompt_right='$(date +%H:%M:%S)'
  prompt+='\[$(tput sc; prompt_right "'${prompt_right}'" "'${c_text}'"; tput rc)\]'

  # Username
  if [[ "$USER" == "root" ]]; then
    # Highlight when logged in as root
    prompt+="${c_user_root}"
  else
    prompt+="${c_user}"
  fi
  prompt+='\u'
  prompt+="${c_reset}"

  # Hostname
  # [[ ! "$HOSTNAME" =~ "$USER" ]]
  if [[ "$(whoami)" != "$(hostname -s)" ]]; then
    prompt+="${prefix_host}"
    if [[ -n "${SSH_TTY}" ]]; then
      # Highlight when connected via SSH
      prompt+="${c_host_ssh}"
    else
      prompt+="${c_host}"
    fi
    prompt+='\h'
    prompt+="${c_reset}"
  fi

  prompt+="${prefix_cwd}"
  # Working directory
  prompt+="${c_cwd}"
  prompt+='\w'
  prompt+="${c_reset}"

  # End of the first line
  local prompt_end='\n'

  # Exit code
  if [[ $exit -eq 0 ]]; then
    prompt_end+="${c_symbol}${prompt_symbol}${c_reset}"
  else
    prompt_end+="${c_symbol_error}${prompt_symbol_error}${c_reset}"
  fi

  # Use ~/.git-prompt.sh to set PS1
  __git_ps1 "${prompt}" "${prompt_end}" "${prefix_git}%s${suffix_git}"

  # # Change master branch color from green to yellow
  # local git_branch='__git_ps1_branch_name'
  # if [[ "${!git_branch}" == "master" ]]; then
  #   PS1="${PS1/"\[\e[32m\]\${${git_branch}}"/"${c_git_master}\${${git_branch}}"}"
  # fi
}

PROMPT_COMMAND='prompt_command'

PS2="${PROMPT_SYMBOL:->} "

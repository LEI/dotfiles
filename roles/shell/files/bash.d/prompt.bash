# https://github.com/necolas/dotfiles
# https://github.com/mathiasbynens/dotfiles/blob/master/.bash_prompt
# https://github.com/demure/dotfiles/blob/master/subbash/prompt

PROMPT_COMMAND='prompt_command'

PROMPT_SYMBOL="› " # $ ✓ →
PROMPT_SYMBOL_ERROR="× " # ! ×

prompt_command() {
  # Exit code
  local exit=$?

  # local ps1_expanded=yes
  # [ -z "$ZSH_VERSION" ] || [[ -o PROMPT_SUBST ]] || ps1_expanded=no
  # [ -z "$BASH_VERSION" ] || shopt -q promptvars || ps1_expanded=no

  local user=$(id -un) # $(whoami)
  local host=$(hostname -s)

  # Default symbols
  local ps1_symbol="${PROMPT_SYMBOL:-$ }"
  local ps2_symbol="${PROMPT_SYMBOL_PS2:-${PROMPT_SYMBOL:-> }}"
  local err_symbol="${PROMPT_SYMBOL_ERROR:-! }"

  # Colors TODO: function
  local c_reset="\[${reset}\]"
  local c_dim="\[${b_yellow}\]" # \[\e[2m\]
  local c_user="\[${blue}\]"
  local c_user_root="\[${red}\]"
  local c_host="\[${b_blue}\]"
  local c_host_ssh="\[${bold}\]\[${red}\]"
  local c_cwd="\[${white}\]"
  local c_branch="\[${red}\]"
  local c_symbol="\[${white}\]"
  local c_symbol_error="\[${red}\]"

  # Start of the primary prompt
  PS1='\n'

  # Terminal title to the current working directory
  PS1+='\[\033]0;\w\007\]'

  # Timestamp to the right
  local prompt_right='$(date +%H:%M:%S)'
  PS1+='\[$(tput sc; prompt_right "'${prompt_right}'" "'${c_dim}'"; tput rc)\]'

  # Username
  if [[ "$USER" == "root" ]]; then
    # Highlight when logged in as root
    PS1+="${c_user_root}"
  else
    PS1+="${c_user}"
  fi
  PS1+='\u'
  PS1+="${c_reset}"

  # Hostname
  # [[ ! "$HOSTNAME" =~ "$USER" ]]
  if [[ "$user" != "$host" ]]; then
    PS1+="${c_dim} at ${c_reset}"
    if [[ -n "${SSH_TTY}" ]]; then
      # Highlight when connected via SSH
      PS1+="${c_host_ssh}"
    else
      PS1+="${c_host}"
    fi
    PS1+='\h'
    PS1+="${c_reset}"
  fi

  PS1+="${c_dim} in ${c_reset}"
  # Working directory
  PS1+="${c_cwd}"
  PS1+='\w'
  PS1+="${c_reset}"

  # Git
  PS1+=$(git_status "${c_dim} on ${c_branch}%s${c_reset}%s")

  # End of the first line
  PS1+='\n'

  # Exit code color and symbol
  if [[ $exit -eq 0 ]]; then
    PS1+="${c_symbol}${ps1_symbol}${c_reset}"
  else
    PS1+="${c_symbol_error}${err_symbol}${c_reset}"
  fi

  # Secondary prompt
  PS2="${ps2_symbol} "
}

prompt_right() {
  local string=${1:-}
  local color=${2:-}
  local margin=${3:-0}
  local columns=

  if [[ -z "$string" ]]; then
    return
  fi

  if [[ -n "$COLUMNS" ]]; then
    columns="$COLUMNS"
  else
    columns=$(tput cols)
  fi

  if [[ -n "$color" ]]; then
    string="${color}${string}"
    margin=$((${margin} - ${#color}))
  fi

  printf "%*s" "$((${columns} - ${margin}))" "${string}"
}

# https://github.com/git/git/blob/master/contrib/completion/git-prompt.sh
git_status() {
  local string=
  local format="${1:- %s %s}"

  # Git prompt symbols
  # PROMPT_SYMBOL_DIRTY="✘"
  # PROMPT_SYMBOL_CLEAN="✔"
  # PROMPT_SYMBOL_ADDED="✚"
  # PROMPT_SYMBOL_MODIFIED="✹"
  # PROMPT_SYMBOL_DELETED="✖"
  # PROMPT_SYMBOL_RENAMED="➜"
  # PROMPT_SYMBOL_UNMERGED="═"
  # PROMPT_SYMBOL_UNTRACKED="✭"

  local repo_info="$(git rev-parse --git-dir --is-inside-git-dir \
    --is-bare-repository --is-inside-work-tree \
    --short HEAD 2>/dev/null)"
  # local rev_parse_exit_code="$?"
  if [[ -z "$repo_info" ]]; then
    return
  fi

  local line
  local file_status
  while IFS= read -r -d '' line; do
    file_status=${line:0:2}
    case $file_status in
      \#\#) branch_line="${line#\#\# }" ;;
      ?M) changed_flag=1 ;; # status+="M" ;; # Modified
      ?A) added_flag=1 ;; # status+="A" ;; # Added
      ?D) deleted_flag=1 ;; # status+="D" ;; # Deleted
      U?) updated_flag=1 ;; # status+="U" ;; # Updated (conflict)
      \?\?) untracked_flag=1 ;; # status+="?" ;; # Untracked
      *) staged_flag=1 ;; # status+="*" ;; # Staged
    esac
  done < <(git status -z --porcelain --branch)
  ## master...origin/master [ahead #]

  local branch="${branch_line%\.\.\.*}"

  local remote_branch="${branch_line#$branch\.\.\.}"

  local ahead=
  if [[ "$branch_line" =~ "[ahead" ]]; then
    remote_branch="${remote_branch% [ahead*}"

    ahead="${branch_line#*[ahead }"
    ahead=" +${ahead%]}"
  fi
  branch="${remote_branch}"

  local flags=
  [[ "$changed_flag" -eq 1 ]] && flags+="~"
  [[ "$added_flag" -eq 1 ]] && flags+="+"
  [[ "$deleted_flag" -eq 1 ]] && flags+="-"
  [[ "$updated_flag" -eq 1 ]] && flags+="!"
  [[ "$untracked_flag" -eq 1 ]] && flags+="?"
  [[ "$staged_flag" -eq 1 ]] && flags+="*"
  [[ -n "$flags" ]] && flags=" [$flags]"

  string="${branch}${ahead}"

  # local count=$(git status --porcelain | wc -l | tr -d '[[:space:]]')
  # local sref=$(git symbolic-ref HEAD 2>/dev/null)
  # if [[ -n "$sref" ]]; then
  #   branch_name=${sref##refs/heads/}
  # fi

  # Repository state
  # local flags=
  # if [[ "$status" -ne 0 ]]; then
  #   flags="*"
  # fi

  # if [[ "$rev_parse_exit_code" = "0" ]]; then
  #   local short_sha="${repo_info##*$'\n'}"
  #   local repo_info="${repo_info%$'\n'*}"

  #   local inside_worktree="${repo_info##*$'\n'}"
  #   repo_info="${repo_info%$'\n'*}"
  #   local bare_repo="${repo_info##*$'\n'}"
  #   repo_info="${repo_info%$'\n'*}"
  #   local inside_gitdir="${repo_info##*$'\n'}"
  #   local g="${repo_info%$'\n'*}"

  #   if [[ "true" = "$inside_worktree" ]] &&
  #     [[ -n "${GIT_PS1_HIDE_IF_PWD_IGNORED-}" ]] &&
  #     [[ "$(git config --bool bash.hideIfPwdIgnored)" != "false" ]] &&
  #     git check-ignore -q .; then
  #     return $exit
  #   fi
  # fi

  printf "$format" "$string" "$flags"
}

# # Colored hints (only when used with 2 arguments as prompt command)
# GIT_PS1_SHOWCOLORHINTS=1

# # * unstaged changes
# # + staged changes
# GIT_PS1_SHOWDIRTYSTATE=1

# # $ stashed items
# GIT_PS1_SHOWSTASHSTATE=1

# # % untracked files
# GIT_PS1_SHOWUNTRACKEDFILES=1

# # Difference between HEAD and its upstream:
# # <           behind
# # >           ahead
# # <>          diverged
# # =           no difference
# #   verbose     show number of commits ahead/behind (+/-) upstream
# #   name        if verbose, then also show the upstream abbrev name
# #   legacy      don't use the '--count' option available in recent
# #               versions of git-rev-list
# #   git         always compare HEAD to @{upstream}
# #   svn         always compare HEAD to your SVN upstream
# GIT_PS1_SHOWUPSTREAM="auto"

# PROMPT_COMMAND='__git_ps1 "\u at \h in \w" "\n\\\$ "'
# __git_ps1 " on %s" | sed -re "s/(\son\s)(\W*)(\w+)(\W*)/\1\2$red\3$white\4/"

# __git_ps1 "${prompt}" "${prompt_end}" "${prefix_git}%s${suffix_git}"
# local c_git_master="\[${yellow}\]"
# # Change master branch color from green to yellow
# local git_branch='__git_ps1_branch_name'
# if [[ "${!git_branch}" == "master" ]]; then
#   PS1="${PS1/"\[\e[32m\]\${${git_branch}}"/"${c_git_master}\${${git_branch}}"}"
# fi

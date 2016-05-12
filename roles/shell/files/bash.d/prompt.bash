# https://github.com/necolas/dotfiles
# https://github.com/mathiasbynens/dotfiles/blob/master/.bash_prompt
# https://github.com/demure/dotfiles/blob/master/subbash/prompt

PROMPT_COMMAND='prompt_command'

prompt_command() {
  # Exit code
  local exit=$?

  # local ps1_expanded=yes
  # [ -z "$ZSH_VERSION" ] || [[ -o PROMPT_SUBST ]] || ps1_expanded=no
  # [ -z "$BASH_VERSION" ] || shopt -q promptvars || ps1_expanded=no

  local user="$(id -un)" # $(whoami)
  local host="$(hostname -s)"

  local reset_color="\[${reset}\]"
  local dim_color="\[${b_yellow}\]"
  local user_color="\[${blue}\]"
  local user_root_color="\[${red}\]"
  local host_color="\[${b_blue}\]"
  local host_ssh_color="\[${bold}${red}\]"
  local cwd_color="\[${white}\]"
  local branch_color="\[${red}\]"
  local symbol_color="\[${white}\]"
  local symbol_error_color="\[${red}\]"

  local git_branch_format="${dim_color} on ${branch_color}%s${reset_color}"
  local git_diff_format="${dim_color}%s${reset_color}"
  local git_flags_format=" ${white}%s${reset_color}"

  # Default symbols
  local ps1_symbol="${PROMPT_SYMBOL:-$ }"
  local ps2_symbol="${PROMPT_SYMBOL_PS2:-${PROMPT_SYMBOL:-> }}"
  local err_symbol="${PROMPT_SYMBOL_ERROR:-! }"

  # Start of the prompt
  local p=''

  # Terminal title to the current working directory
  # Tmux? \033k\w\033\\
  # OSC title? \033]2;\w\033\\
  p+='\033]0;\w\007'
  # FIXME: weird prompt with a title escape sequence on the same line
  p+='\n'

  # Timestamp to the right
  local date='$(date +%H:%M:%S)'
  p+='\[$(tput sc; prompt_right "'${date}'" "'${dim_color}'"; tput rc)\]'

  # Username
  if [[ "$USER" == "root" ]]; then
    # Highlight when logged in as root
    p+="${user_root_color}"
  else
    p+="${user_color}"
  fi
  p+='\u'
  p+="${reset_color}"

  # Hostname
  # [[ ! "$HOSTNAME" =~ "$USER" ]]
  if [[ "$user" != "$host" ]]; then
    p+="${dim_color} at ${reset_color}"
    if [[ -n "${SSH_TTY}" ]]; then
      # Highlight when connected via SSH
      p+="${host_ssh_color}"
    else
      p+="${host_color}"
    fi
    p+='\h'
    p+="${reset_color}"
  fi

  p+="${dim_color} in ${reset_color}"
  # Working directory
  p+="${cwd_color}"
  p+='\w'
  p+="${reset_color}"

  # Git prompt
  # TODO: disable ahead or flags?
  # Colors in format string?
  p+="$(git_status "$git_branch_format" "$git_diff_format" "$git_flags_format")"

  # End of the first line
  p+='\n'

  # Exit code color and symbol
  if [[ $exit -eq 0 ]]; then
    p+="${symbol_color}${ps1_symbol}${reset_color}"
  else
    p+="${symbol_error_color}${err_symbol}${reset_color}"
  fi

  PS1="$p"

  # Secondary prompt
  PS2="${ps2_symbol}"
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
    columns="$(tput cols)"
  fi

  if [[ -n "$color" ]]; then
    string="${color}${string}"
    margin="$((${margin} - ${#color}))"
  fi

  printf "%*s" "$((${columns} - ${margin}))" "${string}"
}

# https://github.com/git/git/blob/master/contrib/completion/git-prompt.sh
# https://github.com/magicmonty/bash-git-prompt/blob/master/gitstatus.sh
git_status() {
  local repo_info="$(git rev-parse --git-dir --is-inside-git-dir \
    --is-bare-repository --is-inside-work-tree \
    --short HEAD 2>/dev/null)"
  # local rev_parse_exit_code="$?"
  if [[ -z "$repo_info" ]]; then
    return
  fi

  # Branch name (master)
  local branch_format="${1:- %s}"
  # Difference between HEAD and its upstream (+n)
  local diff_format="${2:-(%s)}"
  # Repository status flags
  local flags_format="${3:-%s}"

  # TODO: async git fetch

  # local clean=0

  local line file branch_line
  local changed=0 added=0 deleted=0 updated=0 untracked=0 staged=0
  while IFS= read -r -d '' line; do
    file=${line:0:2}
    case $file in
      \#\#) branch_line="${line#\#\# }" ;;
      ?M) ((changed++)) ;; # status+="M" ;; # Modified
      ?A) ((added++)) ;; # status+="A" ;; # Added
      ?D) ((deleted++)) ;; # status+="D" ;; # Deleted
      U?) ((updated++)) ;; # status+="U" ;; # Updated (conflict)
      \?\?) ((untracked++)) ;; # status+="?" ;; # Untracked
      *) ((staged++)) ;; # status+="*" ;; # Staged
    esac
  done < <(git status -z --porcelain --branch)
  ## master...origin/master [ahead #, behind, #]

  local branch="${branch_line%\.\.\.*}"
  # Remote name and remote branch name (origin/master)
  local remote_branch="${branch_line#$branch\.\.\.}"
  branch="${remote_branch% [*}"


  local behind ahead
  # local behind behind_format="${2:-%s}"
  # local ahead ahead_format="${2:-%s}"
  local status pattern
  for status in {ahead,behind}; do
    pattern='(\[|[[:space:]])'${status}'[[:space:]]+([[:digit:]])(,|\])'
    if [[ "$branch_line" =~ $pattern ]]; then
      if [[ "${#BASH_REMATCH[@]}" -ge 2 ]]; then
        # ${!status}="${BASH_REMATCH[2]}"
        declare "${status}"="${BASH_REMATCH[2]}"
      fi
    fi
  done

  # if [[ "$branch_line" =~ "[ahead" ]]; then
  #   ahead="${branch_line#*[ahead }"
  #   ahead="${ahead%]}"
  #   remote_branch="${remote_branch% [ahead*}"
  # fi

  # if [[ -z "$ahead" ]]; then
  #   if [[ "$ahead" -eq 0 ]]; then
  #     # ahead="="
  #     ahead_format="%s"
  #   # elif [[ "$ahead" -gt 0 ]]; then
  #     # Committed changes
  #   fi
  # fi

  local diff=
  [[ -n "$behind" ]] && diff+="<" # "$behind<"
  [[ -n "$ahead" ]] && diff+=">" # ">$ahead"
  [[ -n "$diff" ]] || diff="="

  local flags=
  # TODO: color and symbol vars
  [[ "$staged" -gt 0 ]] && flags+="*"
  [[ "$updated" -gt 0 ]] && flags+="!"
  [[ "$untracked" -gt 0 ]] && flags+="?"
  [[ "$changed" -gt 0 ]] && flags+="~"
  [[ "$added" -gt 0 ]] && flags+="+"
  [[ "$deleted" -gt 0 ]] && flags+="-"
  if [[ -n "$flags" ]]; then
    flags="$flags"
  else
    # clean=1
    # flags -> PROMPT_SYMBOL_CLEAN?
    flags_format="%s"
  fi

  printf "${branch_format}${diff_format}${flags_format}" "${branch}" "${diff}" "${flags}"

  # local count=$(git status --porcelain | wc -l | tr -d '[[:space:]]')
  # local sref=$(git symbolic-ref HEAD 2>/dev/null)
  # if [[ -n "$sref" ]]; then
  #   branch_name=${sref##refs/heads/}
  # fi

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
# local git_master_color="${yellow}"
# # Change master branch color from green to yellow
# local git_branch='__git_ps1_branch_name'
# if [[ "${!git_branch}" == "master" ]]; then
#   PS1="${PS1/"\e[32m\${${git_branch}}"/"${git_master_color}\${${git_branch}}"}"
# fi

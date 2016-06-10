# https://github.com/necolas/dotfiles
# https://github.com/mathiasbynens/dotfiles/blob/master/.bash_prompt
# https://github.com/demure/dotfiles/blob/master/subbash/prompt
# https://wiki.archlinux.org/index.php/Bash/Prompt_customization
# https://github.com/git/git/blob/master/contrib/completion/git-prompt.sh
# https://github.com/magicmonty/bash-git-prompt/blob/master/gitstatus.sh

__prompt_command() {
  local exit=$?

  if [[ "$exit" -eq 0 ]]; then
    EXIT_COLOR=""
  else
    EXIT_COLOR="${red}"
  fi
}

__prompt_right() {
  local width

  if [[ -n "$COLUMNS" ]]; then
    width="$COLUMNS"
  else
    width="$(tput cols)"
  fi

  printf "%*s\r" "$width" "$1"
}

__prompt_string() {
  local prompt_symbol="${1:-\$ }"
  local p

  p='\n'

  # Update the terminal title
  # Tmux? \033k\w\033\\
  # OSC title? \033]2;\w\033\\
  # p+='\[\033]0;\w\007\]'
  p+='\[\e]2;\w\a\]'

  # Right align the time
  # p+='\[$(tput sc; __prompt_right "\t"; tput rc)\]'

  # printf "%*(%T)T\r" "$width"
  # p+='\[$(tput sc; printf "%*s\r" "$width" "$(date +%T)"; tput rc)\]'
  # p+='\[$(tput sc; printf "%*s" "$width" "\t"; tput rc)\]'

  # Highlight the user when logged in as root
  if [[ "${USER}" = "root" ]]; then
    p+='\[${red}\]'
  else
    p+='\[${blue}\]'
  fi
  p+='\u'
  p+='\[${reset}\]'

  # Display the host only if different of the user
  if [[ "${USER}" != "${HOSTNAME%%.*}" ]]; then
    p+=' at'
    # Highlight when connected via SSH
    if [[ -n "${SSH_TTY}" ]]; then
      p+='\[${red}\]'
    else
      p+='\[${cyan}\]'
    fi
    p+=' \h'
    p+='\[${reset}\]'
  fi

  # Working directory
  p+=' in'
  p+='\[${white}\]'
  p+=' \w'

  p+='\[${reset}\]'

  # Git status
  # p+='$(__prompt_git " on " "%s" "\[${white}\]%s\[${reset}\]")'
  p+='$(__prompt_git)'

  p+='\n'

  p+='\[${EXIT_COLOR}\]'
  p+="$prompt_symbol"
  p+='\[${reset}\]'

  printf "%s" "$p"
}

__prompt_git() {
  local exit=$?
  local repo_info="$(git rev-parse --git-dir --is-inside-git-dir \
    --is-bare-repository --is-inside-work-tree \
    --short HEAD 2>/dev/null)"
  local rev_parse_exit="$?"
  if [[ -z "$repo_info" ]]; then
    return $exit
  fi

  local file line branch_line dirty=0
  while IFS= read -r -d '' line; do
    file=${line:0:2}
    case $file in
      \#\#) branch_line="${line#\#\# }" ;;
      *) ((dirty++)) ;;
    esac
  done < <(git status -z --porcelain --branch) 2>/dev/null

  local branch="${branch_line%\.\.\.*}"
  branch="${branch##* }"

  local flag branch_color
  if [[ "$dirty" -gt 0 ]]; then
    flag="*"
    if [[ "$branch" == "master" ]]; then
      branch_color="red"
    else
      branch_color="orange"
    fi
  else
    branch_color="green"
  fi

  local behind ahead var pattern
  for var in {ahead,behind}; do
    pattern='(\[|[[:space:]])'${var}'[[:space:]]+([[:digit:]])(,|\])'
    if [[ "$branch_line" =~ $pattern ]]; then
      if [[ "${#BASH_REMATCH[@]}" -ge 2 ]]; then
        # ${!var}="${BASH_REMATCH[2]}"
        declare "${var}"="${BASH_REMATCH[2]}"
      fi
    fi
  done

  local diff=
  [[ -n "$behind" ]] && diff+="<"
  [[ -n "$ahead" ]] && diff+=">"

  local printf_format="${1:- on %s%s}"
  printf -- "${printf_format}" "${!branch_color}$branch${reset}" "${white}$flag${reset}$diff"
}

# p+='$([[ -n $(git branch 2> /dev/null) ]] && echo " on ")\[${white}\]$(parse_git_branch)\[${reset}\]'
# parse_git_dirty() {
#   [[ $(git status 2> /dev/null | tail -n1) != *"working directory clean"* ]] && echo "*"
# }
# parse_git_branch() {
#   git branch --no-color 2> /dev/null | sed -e '/^[^*]/d' -e "s/* \(.*\)/\1$(parse_git_dirty)/"
# }

# PROMPT_SYMBOL_DIRTY="✘"
# PROMPT_SYMBOL_CLEAN="✔"
# PROMPT_SYMBOL_ADDED="✚"
# PROMPT_SYMBOL_MODIFIED="✹"
# PROMPT_SYMBOL_DELETED="✖"
# PROMPT_SYMBOL_RENAMED="➜"
# PROMPT_SYMBOL_UNMERGED="═"
# PROMPT_SYMBOL_UNTRACKED="✭"
custom_prompt_git() {
  local exit=$?
  local repo_info="$(git rev-parse --git-dir --is-inside-git-dir \
    --is-bare-repository --is-inside-work-tree \
    --short HEAD 2>/dev/null)"
  local rev_parse_exit="$?"
  if [[ -z "$repo_info" ]]; then
    return $exit
  fi

  # Branch name (master)
  local branch_prefix="${1:- git:}"
  # Difference between HEAD and its upstream (+n)
  local diff_format="${2:-(%s)}"
  # Repository status flags
  local flags_format="${3:-%s}"

  local short_sha
  if [[ "$rev_parse_exit" == "0" ]]; then
    short_sha="${repo_info##*$'\n'}"
    repo_info="${repo_info%$'\n'*}"
  fi
  local inside_worktree="${repo_info##*$'\n'}"
  repo_info="${repo_info%$'\n'*}"
  local bare_repo="${repo_info##*$'\n'}"
  repo_info="${repo_info%$'\n'*}"
  local inside_gitdir="${repo_info##*$'\n'}"
  local g="${repo_info%$'\n'*}"

  # Hide if the current directory is ignored
  # if [[ "$inside_worktree" = "true" ]] && git check-ignore -q . 2>/dev/null; then
  #   # [[ -n "${GIT_PS1_HIDE_IF_PWD_IGNORED-}" ]]
  #   # [[ "$(git config --bool bash.hideIfPwdIgnored)" != "false" ]]
  #   return $exit
  # fi

  if [[ "$bare_repo" = "true" ]]; then
    printf "%s" " in bare repo"
    return $exit
  elif [[ "$inside_gitdir" = "true" ]]; then
    printf "%s" " in git dir"
    return $exit
  # elif [[ "$inside_worktree" = "true" ]]; then
  fi

  local line file branch_line
  local changed=0 added=0 deleted=0 updated=0 untracked=0 staged=0

  while IFS= read -r -d '' line; do
    file=${line:0:2}
    case $file in
      \#\#) branch_line="${line#\#\# }" ;;
      ?M) ((changed++)) ;;
      ?A) ((added++)) ;;
      ?D) ((deleted++)) ;;
      U?) ((updated++)) ;;
      \?\?) ((untracked++)) ;;
      *) ((staged++)) ;;
    esac
  done < <(git status -z --porcelain --branch) 2>/dev/null
  # FIXME fatal: This operation must be run in a work tree
  ## master...origin/master [ahead #, behind, #]

  local branch remote_branch
  local behind ahead
  local var pattern

  # Local branch name (master)
  branch="${branch_line%\.\.\.*}"
  # TODO handle white spaces in branch name?
  branch="${branch##* }"

  # __git_branch="${branch}"

  # Remote and remote branch name (origin/master)
  # remote_branch="${branch_line#*\.\.\.}"
  # remote_branch="${remote_branch% [*}"

  for var in {ahead,behind}; do
    pattern='(\[|[[:space:]])'${var}'[[:space:]]+([[:digit:]])(,|\])'
    if [[ "$branch_line" =~ $pattern ]]; then
      if [[ "${#BASH_REMATCH[@]}" -ge 2 ]]; then
        # ${!var}="${BASH_REMATCH[2]}"
        declare "${var}"="${BASH_REMATCH[2]}"
      fi
    fi
  done

  # Signs
  local diff_flags=
  local behind_flag="<"
  local ahead_flag=">"

  local file_flags=
  local added_flag="+"
  local changed_flag="~"
  local deleted_flag="-"
  local staged_flag="*"
  local untracked_flag="?"
  local updated_flag="!"
  # stashed -> $

  [[ -n "$behind" ]] && diff_flags+="$behind_flag"
  [[ -n "$ahead" ]] && diff_flags+="$ahead_flag"
  [[ -z "$diff_flags" ]] && diff_format="%s" # diff_flags="=" # Up to date

  # Display count if there is more than one file
  # [[ "$staged" -gt 1 ]] && file_flags+="$staged"

  [[ "$staged" -gt 0 ]] && file_flags+="$staged_flag"
  # Conflicts?
  [[ "$added" -gt 0 ]] && file_flags+="$added_flag"
  [[ "$changed" -gt 0 ]] && file_flags+="$changed_flag"
  [[ "$deleted" -gt 0 ]] && file_flags+="$deleted_flag"
  [[ "$untracked" -gt 0 ]] && file_flags+="$untracked_flag"
  [[ "$updated" -gt 0 ]] && file_flags+="$updated_flag"

  [[ -z "$file_flags" ]] && flags_format="%s"

  if [[ -n "$behind" ]]; then
    branch_color="${red}"
  elif [[ -n "$ahead" ]]; then
    branch_color="${orange}"
  elif [[ -n "$file_flags" ]]; then
    branch_color="${yellow}"
  else
    branch_color="${green}"
  fi

  branch="${branch_color}${branch}${reset}"

  local printf_format="%s${diff_format}${flags_format}"
  printf -- "${printf_format}" "${branch_prefix}${branch}" "${diff_flags}" "${file_flags}"
}

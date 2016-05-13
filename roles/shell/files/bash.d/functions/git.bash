# Git

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

  local short_sha="${repo_info##*$'\n'}"

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

  # Branch name (master)
  local branch_format="${1:- %s}"
  # Difference between HEAD and its upstream (+n)
  local diff_format="${2:-(%s)}"
  # Repository status flags
  local flags_format="${3:-%s}"

  local line file branch_line
  local changed=0 added=0 deleted=0 updated=0 untracked=0 staged=0

  local branch remote_branch
  local behind ahead
  local var pattern

  local diff_flags=
  local behind_flag="<"
  local ahead_flag=">"

  local file_flags=
  local staged_flag="*"
  local updated_flag="!"
  local untracked_flag="?"
  local changed_flag="~"
  local added_flag="+"
  local deleted_flag="-"

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
  done < <(git status -z --porcelain --branch)
  ## master...origin/master [ahead #, behind, #]

  # Local branch name (master)
  branch="${branch_line%\.\.\.*}"
  # Remote and remote branch name (origin/master)
  # remote_branch="${branch_line#*\.\.\.}"
  # remote_branch="${remote_branch% [*}"

  # Fallback
  [[ -z "$branch" ]] && branch="$short_sha"

  for var in {ahead,behind}; do
    pattern='(\[|[[:space:]])'${var}'[[:space:]]+([[:digit:]])(,|\])'
    if [[ "$branch_line" =~ $pattern ]]; then
      if [[ "${#BASH_REMATCH[@]}" -ge 2 ]]; then
        # ${!var}="${BASH_REMATCH[2]}"
        declare "${var}"="${BASH_REMATCH[2]}"
      fi
    fi
  done

  [[ -n "$behind" ]] && diff_flags+="$behind_flag"
  [[ -n "$ahead" ]] && diff_flags+="$ahead_flag"
  [[ -z "$diff_flags" ]] && diff_format="%s" # diff_flags="=" # Up to date

  # Display count if there is more than one staged file
  [[ "$staged" -gt 1 ]] && file_flags+="$staged"
  [[ "$staged" -gt 0 ]] && file_flags+="$staged_flag"

  # Conflicts?
  [[ "$updated" -gt 0 ]] && file_flags+="$updated_flag"
  [[ "$untracked" -gt 0 ]] && file_flags+="$untracked_flag"
  [[ "$changed" -gt 0 ]] && file_flags+="$changed_flag"
  [[ "$added" -gt 0 ]] && file_flags+="$added_flag"
  [[ "$deleted" -gt 0 ]] && file_flags+="$deleted_flag"

  if [[ -n "$file_flags" ]]; then
    # Display flags (colors?)
    file_flags="$file_flags"
  else
    # PROMPT_SYMBOL_CLEAN?
    flags_format="%s"
  fi

  # TODO gitstring
  local printf_format="${branch_format}${diff_format}${flags_format}"
  printf -- "${printf_format}" "${branch}" "${diff_flags}" "${file_flags}"
}

# Pastebin
# http://ptpb.pw/#shell-functions

PB_PROVIDER="https://ptpb.pw"
PB_DEFAULT_OPTS=""
# export PB_PROVIDER PB_DEFAULT_OPTS

# local args="$@"
arg() {
  local a="$1" # Short argument name
  local pattern="-$a([a-z]*)*"
  local arg_var="${2:-}" # Variable name
  local next arg
  [[ -n "$arg_var" ]] && echo arg_var $arg_var
  if [[ $args =~ $pattern ]]
  then next="${BASH_REMATCH[1]}" arg="${args#-* }" arg="${arg%% *}"
    echo "next: $next, a: $a, args: $args"
    if [[ -n "$arg_var" ]]
    then
      if [[ -n "$arg" ]] && [[ "$arg" == -* ]]
      then error "-$a: Missing argument value (found: '$arg')"; return 1
      fi
      if [[ -n "$arg" ]] && [[ "$args" != "$arg"* ]]
      then eval "$arg_var="$arg"" # If a value is found
      else error "-$a: Missing argument value"; return 1
      fi
      if [[ -n "$next" ]]
      then args="${args/-$a* $arg/-$next}" # $arg}"
      else args="${args#-$a $arg}" # args="${args#* }"
      fi
      echo eval "$arg_var=$arg"
    else
      echo eval "$a=true"
      eval "$a=true"
      args="${args#-$a}"
      [[ -n "$next" ]] && args="-$args"
      # then args="${args/-$a/-}"
      # else args="${args#-$a}"
    fi
    echo ">>> next: $next, a: $a, args: $args"
  else error "$args: Not matching /$pattern/"; return 1
  fi
}

pb() {
  local args="$@"
  local url="$PB_PROVIDER"
  local opts=("$PB_DEFAULT_OPTS")
  local file private p sunset vanity uuid # Parameters
  local update remove # Actions
  while true # [[ -n "$args" ]]
  do local a= next= arg= pattern=
    local p= R= U=
    echo ARGS \'$args\'
    # Trim leading and trailing [[:spaces:]]
    args="${args# }" args="${args% }"
    case "$args" in
      -f*) arg f file || return $? ;;
      -h|--help) echo "https://github.com/HalosGhost/pbpst/blob/master/doc/pbpst.rst"; return 1 ;;
      -p*) arg p || return $?; private="$p" ;;
      -R*) arg R || return $?; remove="$R" ;;
      -U*) arg U || return $?; update="$U" ;;
      -u*) arg u uuid || return $? ;;
      -x*) arg x sunset || return $? ;;
      -*) error "${args%% *}: Invalid argument"; return 1 ;;
      '') break ;;
      *) echo "$args: Not matched!"; break ;;
    esac
  done

  case true in
    $update)
      [[ -n "$uuid" ]] && url+="/$uuid" || error "Missing uuid"
      [[ -n "$sunset" ]] && opts+=("-F sunset=$sunset")
      [[ -n "$private" ]] && opts+=("-F p=1")
      ;;
    $remove)
      [[ -n "$uuid" ]] && url+="/$uuid" || error "Missing uuid"
      ;;
    *) # Create
      [[ -n "$vanity" ]] && url+="/~$vanity"
      [[ -n "$sunset" ]] && opts+=("-F sunset=$sunset")
      [[ -n "$private" ]] && opts+=("-F p=1")
      ;;
  esac

  echo curl ${opts[@]} -F "c=@${file:--}" $url
}

pb_update() {
  local file="${1:-}"
  local uuid="${1:-}"
  local opts="-X PUT ${3:-}"
  pb "$file" "$opts"
  curl ${opts[@]} -F "c=@${file:--}" "http://ptpb.pw/$uuid"
}

pb_delete() {
  local uuid="${1:-}"; shift
  local file="${1:-}"; shift
  local opts=("-X PUT" "$@")
  curl ${opts[@]} -F "c=@${file:--}" "$PBPROVIDER/$uuid"
}

# Copy the url of the uploaded paste
pbx() {
  local copy
  if has xsel
  then copy="xsel -l /dev/null -b"
  # elif has xclip # xclipboard
  # elif has pbcopy
  else error "No clipboard manager found"
    return 1
  fi
  curl -sF "c=@${1:--}" -w "%{redirect_url}" 'http://ptpb.pw/?r=1' -o /dev/stderr | "$copy"
}

# Capture screenshot
pbs () {
  gm import -window ${1:-root} /tmp/$$.png
  pbx /tmp/$$.png
}

# Record terminal
pbs () {
  asciinema rec /tmp/$$.json
  pbx /tmp/$$.json
}

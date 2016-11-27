# Pastebin
# http://ptpb.pw/#shell-functions
# https://github.com/HalosGhost/pbpst

PB_PROVIDER="https://ptpb.pw"
PB_CURL_OPTS=""

# local args="$@"
arg() {
  local a="$1" # Short argument name
  local next arg pattern="-$a([a-z]*)*"
  local arg_var="${2:-}" # Variable name
  if [[ $args =~ $pattern ]]
  then next="${BASH_REMATCH[1]}" arg="${args#-* }" arg="${arg%% *}"
    if [[ -n "$arg_var" ]]
    then
      if [[ -n "$arg" ]] && [[ "$arg" == -* ]]
      then error "-$a: Missing argument value (found: '$arg')"; return 1
      fi
      if [[ -n "$arg" ]] && [[ "$args" != "$arg"* ]]
      then eval "$arg_var="$arg"" # If a value is found
        # echo "DEBUG eval $arg_var=$arg" >&2
      else error "-$a: Missing argument value"; return 1
      fi
      if [[ -n "$next" ]]
      then args="${args/-$a* $arg/-$next}" # $arg}"
      else args="${args#-$a $arg}" # args="${args#* }"
      fi
    else
      eval "$a=true"
      # echo "DEBUG eval $a=true" >&2
      args="${args#-$a}"
      if [[ -n "$next" ]]
      then args="-$args"
      fi
      # then args="${args/-$a/-}"
      # else args="${args#-$a}"
    fi
  else error "$args: Not matching /$pattern/"; return 1
  fi
}

pb() {
  local args="$@"
  local url="$PB_PROVIDER"
  local opts=""
  local create remove shorten update # Actions
  local private file handler uuid vanity sunset # Parameters
  while [[ -n "$args" ]]
  do
    local C= R= S= U=
    local p= f= h= u= v= x=
    # echo "DEBUG ARGS -> '$args'" >&2
    # Trim leading and trailing [[:spaces:]]
    args="${args# }" args="${args% }"
    case "$args" in
      -h|--help) echo "Usage:"; return 1 ;;
      -C*) arg C && create="$C" || return $? ;;
      -R*) arg R && remove="$R" || return $? ;;
      -S*) arg S && shorten="$S" || return $? ;;
      -U*) arg U && update="$U" || return $? ;;
      -p*) arg p && private="$p" || return $? ;;
      -f*) arg f file || return $? ;;
      -h*) arg h handler || return $? ;;
      -u*) arg u uuid || return $? ;;
      -v*) arg v vanity || return $? ;;
      -x*) arg x sunset || return $? ;;
      -*) error "${args%% *}: Invalid argument"; return 1 ;;
      '') break ;;
      *) echo "$args: Not matched!"; break ;;
    esac
  done

  # printf "%s\n" "create:$create,remove:$remove,shorten:$shorten,update:$update" >&2
  # printf "%s\n" "priv:$private,file:$f,uuid:$u,vanity:$v,sunset:$x" >&2

  if [[ -z "$create$update$remove$shorten" ]]
  then error "$@: Missing action (-Create, -Remove, -Shorten, -Update)"; return 1
  elif [[ "$create$update$remove$shorten" != true ]]
  then error "$@: Invalid action"; return 1
  fi
  case true in
    $create) # POST
      [[ -n "$private" ]] && opts+=" -F p=1"
      [[ -n "$sunset" ]] && opts+=" -F sunset=$sunset"
      [[ -n "$vanity" ]] && url+="/~$vanity"
      opts+=" -F c=@${file:--}"
      ;;
    $update) opts+=" -X PUT"
      if [[ -z "$uuid" ]]
      then error "-S: Invalid arguments (missing uuid)"; return 1
      else url+="/$uuid"
      fi
      [[ -n "$private" ]] && opts+=" -F p=1"
      [[ -n "$sunset" ]] && opts+=" -F sunset=$sunset"
      opts+=" -F c=@${file:--}"
      ;;
    $remove) opts+=" -X DELETE"
      if [[ -n "$private$file$vanity$sunset" ]]
      then error "-R: Too many arguments"; return 1
      elif [[ -z "$uuid" ]]
      then error "-S: Invalid arguments (missing uuid)"; return 1
      else url+="/$uuid"
      fi
      ;;
    $shorten) # POST
      if [[ -n "$private$file$uuid$vanity$sunset" ]]
      then error "-S: Too many arguments"; return 1
      # elif [[ -z "$link" ]]
      # then error "-S: Invalid arguments (missing link)"; return 1
      else url+="/u" # <<< $link
      fi
      # opts+=" -F c=@-"
      opts+=" -F c=@${file:--}"
      ;;
    *) error "$@: Invalid action"; return 1 ;;
  esac

  [[ -n "$PB_CURL_OPTS" ]] && opts="$PB_CURL_OPTS $opts"
  [[ -n "$handler" ]] && url+="?$handler=1"

  # echo curl ${opts[@]} $url >&2
  curl ${opts[@]} $url
}

# pb_update() {
#   local file="${1:-}"
#   local uuid="${1:-}"
#   local opts="-X PUT ${3:-}"
#   pb "$file" "$opts"
#   curl ${opts[@]} -F "c=@${file:--}" "http://ptpb.pw/$uuid"
# }

# pb_delete() {
#   local uuid="${1:-}"; shift
#   local file="${1:-}"; shift
#   local opts=("-X PUT" "$@")
#   curl ${opts[@]} -F "c=@${file:--}" "$PBPROVIDER/$uuid"
# }

# Copy the url of the uploaded paste
pbx() {
  local copy
  if has xsel
  then copy="xsel -l /dev/null -b"
  # elif has xclip / xclipboard
  elif has pbcopy
  then copy="pbcopy" # -pboard general
  else error "$(uname -s): No clipboard manager found"; return 1
  fi
  local opts="-h r $@" # ?r=1
  local curl_opts="$PB_CURL_OPTS -s -w %{redirect_url} -o /dev/stderr"
  PB_CURL_OPTS="$curl_opts" pb $opts | "$copy"
  # curl -sF "c=@${1:--}" -w "%{redirect_url}" 'http://ptpb.pw/?r=1' -o /dev/stderr | "$copy"
}

# Encrypt file with GPG symetric cipher
pbg() { # Always pbx -Cf "$file" ?
  gpg -o - -c "$file" | pbx $@
} # Decrypt with curl <pasteurl> | gpg -d

# Capture screenshot
pbs () {
  local win="${1:-root}"
  local tmp=/tmp/$$.png
  gm import -window $win $tmp
  pbx $tmp
}

# Record terminal
pbs () {
  local tmp=/tmp/$$.json
  asciinema rec $tmp
  pbx $tmp
}

# Pastebin
# http://ptpb.pw/#shell-functions
# https://github.com/HalosGhost/pbpst

PB_PROVIDER="https://ptpb.pw"
PB_CURL_OPTS=""
PB_USAGE="Usage: pb [-CRUShdpfuvx]"

# set -e
shopt -s extglob

# local args="$@"
arg() {
  local a="$1" # Argument name
  local prefix next arg pattern="(-|--)($a)*([a-z])?( |=)*" # ( |=)
  local var="${2:-}" # Variable name
  if [[ $args =~ $pattern ]]
  then # >&2 printf "MATCH %s\n" "${BASH_REMATCH[@]}"
    prefix="${BASH_REMATCH[1]}"
    a="${BASH_REMATCH[2]}"
    next="${BASH_REMATCH[3]}"
    sep="${BASH_REMATCH[4]:- }"
    # >&2 echo "B4 arg: $arg, args: $args"
    arg="${args#${prefix}*${sep}}" arg="${args%% -*}" # arg="${arg%%${prefix}*}" # arg="${arg%%${sep}*}"
    if [[ -n "$var" ]] && [[ "$var" != "bool" ]]
    then
      arg="${arg#${prefix}${a}${sep}}"
      # >&2 echo "arg: $arg, args: $args"
      if [[ -n "$arg" ]] && [[ "$arg" == ${prefix}* ]]
      # then error "${prefix}$a: Missing argument value (found: '$arg')"; return 1
      then pberr "missing value -- $a" "found: $arg"; return 1
      fi
      if [[ -n "$arg" ]] && [[ "$args" != "$arg"* ]]
      then
        # >&2 echo "$a -> eval $var=\"$arg\""
        eval $var=\"$arg\"
      # else error "${prefix}$a: Missing argument value"; return 1
      else pberr "missing value -- $a"; return 1
      fi
      # >&2 echo "prefix: $prefix, a: $a, sep: $sep, arg: $arg, next: '$next'"
      if [[ -n "$next" ]]
      then args="${args/${prefix}$a*${sep}$arg/${prefix}$next}" # $arg}"
      else args="${args#${prefix}$a${sep}$arg}" # args="${args#* }"
      fi
    else
      # >&2 echo "$a -> eval ${var:-a}=true"
      eval "${var:-a}=true"
      args="${args#${prefix}$a}"
      if [[ -n "$next" ]]
      then args="${prefix}$args"
      else args="${args#$sep}"
      fi
      # then args="${args/-$a/-}"
      # else args="${args#-$a}"
    fi
  else error "$args: Not matching /$pattern/"; return 1
  fi
}

# larg() {
#   local arg="$1"
#   local sep="${2:- }"
#   args="${args#--$arg$sep}"
#   eval "$arg="${args%% *}""
#   args="${args#${!arg}}"
# }

pb() {
  local args="$@"
  local url="$PB_PROVIDER"
  local opts=""
  local method create update remove shorten # Actions
  local debug private file handler uuid vanity sunset # Parameters
  while [[ -n "$args" ]]
  do local bool= # f= u= v= x=
    # [[ -n "$debug" ]] || [[ "$args" == *"-d"* ]] && echo "ARGS -> '$args'" >&2
    # Trim leading and trailing [[:spaces:]]
    args="${args# }" args="${args% }"
    case "$args" in
      ''|--\ *) break ;;
      -h*|--help*) pberr; return 1 ;;
      -d*|--debug*) arg "d|debug" bool && debug="$bool" || return $? ;;
      -p*|--private*) arg "p|private" bool && private="$bool" || return $? ;;
      -C*) arg C bool && create="$bool" || return $? ;;
      -U*) arg U bool && update="$bool" || return $? ;;
      -R*) arg R bool && remove="$bool" || return $? ;;
      -S*) arg S bool && shorten="$bool" || return $? ;;
      -f*|--file*) arg "f|file" file || return $? ;;
      -u*|--uuid*) arg "u|uuid" uuid || return $? ;;
      -v*|--vanity*) arg "v|vanity" vanity || return $? ;;
      -x*|--sunset*) arg "x|sunset" sunset || return $? ;;
      --handler*) arg "handler" handler || return $? ;;
      # --handler=*) args="${args#--handler=}" handler="${args%% *}" args="${args#$handler}" ;;
      # -*) pberr "illegal option ${args%% *}"; return 1 ;;
      *) pberr "illegal option -- $args"; return 1 break ;;
    esac
  done

  # if [[ -n "$debug" ]]
  # then
  #   printf "ACTION %s\n" "create:$create, remove:$remove, shorten:$shorten, update:$update" >&2
  #   printf "PARAM %s\n" "priv:$private, file:$file, uuid:$uuid, vanity:$vanity, sunset:$sunset" >&2
  # fi

  if [[ -z "$create$update$remove$shorten" ]]
  then pberr "missing option -CURS"; return 1
  elif [[ "$create$update$remove$shorten" != true ]]
  then pberr "illegal action -CURS"; return 1
  fi
  case true in
    $create) # POST
      if [[ -n "$uuid" ]]
      then pberr "illegal option -- uuid"; return 1
      fi
      [[ -n "$private" ]] && opts+=" -F p=1"
      [[ -n "$sunset" ]] && opts+=" -F sunset=$(get_seconds $sunset)"
      [[ -n "$vanity" ]] && url+="/~$vanity"
      [[ -f "$file" ]] || [[ -z "$file" ]] && file="@${file:--}" # -e -f TODO
      ;;
    $update) method="PUT"
      if [[ -n "$vanity" ]]
      then pberr "illegal option -- vanity"; return 1
      elif [[ -z "$uuid" ]]
      then pberr "missing option -- uuid"; return 1
      else url+="/$uuid"
      fi
      [[ -n "$private" ]] && opts+=" -F p=1"
      [[ -n "$sunset" ]] && opts+=" -F sunset=$(get_seconds $sunset)"
      [[ -f "$file" ]] || [[ -z "$file" ]] && file="@${file:--}"
      ;;
    $remove) method="DELETE"
      if [[ -n "$private$file$vanity$sunset" ]]
      then pberr "illegal option -- p|f|v|s"; return 1
      elif [[ -z "$uuid" ]]
      then pberr "missing option -- uuid"; return 1
      else url+="/$uuid"
      fi
      ;;
    $shorten) # POST
      if [[ -n "$private$uuid$vanity$sunset" ]]
      then pberr "illegal option -- p|u|v|s"; return 1
      # elif [[ -z "$link" ]]
      # then pberr "-S: Invalid arguments (missing link)"; return 1
      else url+="/u" # <<< $link
      fi
      [[ -f "$file" ]] || [[ -z "$file" ]] && file="@${file:--}"
      # opts+=" -F c=@-"
      # opts+=" -F "c=$file""
      ;;
    *) pberr "illegal action -- $@"; return 1 ;;
  esac

  # if [[ -n "$sunset" ]] && [[ "$sunset" -gt 0 ]]
  # then pberr "--sunset: Must be a number"; return 1
  # else sunset="$(get_seconds $sunset)"
  # fi

  [[ -n "$file" ]] && opts+=" -F "c=$file""
  [[ -n "$method" ]] && opts+=" -X $method"
  local curl_opts="$PB_CURL_OPTS $opts"
  if [[ -n "$handler" ]]
  then url+="?$handler=1"
  # elif [[ -n "$terminal" ]]
  # then url+="?t=1"
  fi

  # echo curl ${opts[@]} $url >&2
  if [[ -n "$debug" ]]
  then >&2 echo curl $curl_opts $url
  else curl $curl_opts $url
  fi
}

pberr() {
  [[ -n "${1:-}" ]] && error "pb: $1"
  error "$PB_USAGE"
}

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
  local opts="--handler=r $@" # ?r=1
  local curl_opts="$PB_CURL_OPTS -s -w %{redirect_url} -o /dev/stderr"
  PB_CURL_OPTS="$curl_opts" pb $opts | "$copy"
  # curl -sF "c=@${1:--}" -w "%{redirect_url}" 'http://ptpb.pw/?r=1' -o /dev/stderr | "$copy"
}

# Encrypt file with GPG symetric cipher
pbg() { # Decrypt with curl <pasteurl> | gpg -d
  gpg -o - -c "$1" | pbx -C # $@
}

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

# Pastebin
# http://ptpb.pw/#shell-functions
# https://github.com/HalosGhost/pbpst

PB_PROVIDER="https://ptpb.pw"
PB_CURL_OPTS=""

shopt -s extglob

# local args="$@"
arg() {
  local a="$1" # Argument name
  local prefix next arg pattern="(-|--)($a)([a-z]*)*" # ( |=)
  local var="${2:-}" # Variable name
  if [[ $args =~ $pattern ]]
  then # >&2 printf "MATCH %s\n" "${BASH_REMATCH[@]}"
    prefix="${BASH_REMATCH[1]}"
    a="${BASH_REMATCH[2]}"
    next="${BASH_REMATCH[3]}"
    sep=" " # ${BASH_REMATCH[4]}}
    arg="${args#${prefix}*${sep}}" arg="${arg%%${sep}*}"
    if [[ -n "$var" ]] && [[ "$var" != "bool" ]]
    then
      if [[ -n "$arg" ]] && [[ "$arg" == ${prefix}* ]]
      then error "${prefix}$a: Missing argument value (found: '$arg')"; return 1
      fi
      if [[ -n "$arg" ]] && [[ "$args" != "$arg"* ]]
      then eval "$var="$arg"" # If a value is found
        # echo "-> eval $var=$arg ($a)" >&2
      else error "${prefix}$a: Missing argument value"; return 1
      fi
      if [[ -n "$next" ]]
      then args="${args/${prefix}$a*${sep}$arg/${prefix}$next}" # $arg}"
      else args="${args#${prefix}$a${sep}$arg}" # args="${args#* }"
      fi
    else # eval "$a=true"
      eval "${var:-a}=true"
      # echo "-> eval ${var:-a}=true ($a)" >&2
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

larg() {
  local arg="$1"
  local sep="${2:- }"
  args="${args#--$arg$sep}"
  eval "$arg="${args%% *}""
  args="${args#${!arg}}"
}

pb() {
  local args="$@"
  local url="$PB_PROVIDER"
  local opts=""
  local create remove shorten update # Actions
  local debug private file handler uuid vanity sunset # Parameters
  while [[ -n "$args" ]]
  do local bool= # f= u= v= x=
    # [[ -n "$debug" ]] || [[ "$args" == *"-d"* ]] && echo "ARGS -> '$args'" >&2
    # Trim leading and trailing [[:spaces:]]
    args="${args# }" args="${args% }"
    case "$args" in
      -h*|--help*) error "Usage: pb [-CRSUpfruvx]"
        error "create [f], remove <u>, shorten <<<, update <u>..."
        return 1 ;;
      -d*|--debug*) arg "d|debug" bool && debug="$bool" || return $? ;;
      -p*) arg p bool && private="$bool" || return $? ;;
      -C*) arg C bool && create="$bool" || return $? ;;
      -R*) arg R bool && remove="$bool" || return $? ;;
      -S*) arg S bool && shorten="$bool" || return $? ;;
      -U*) arg U bool && update="$bool" || return $? ;;
      -f*) arg f file || return $? ;;
      --file\ *) larg file || return $? ;;
      --file=*) larg file = || return $? ;;
      -u*) arg u uuid || return $? ;;
      --uuid\ *) larg uuid || return $? ;;
      --uuid=*) larg uuid = || return $? ;;
      -v*) arg v vanity || return $? ;;
      --vanity\ *) larg vanity || return $? ;;
      --vanity=*) larg vanity = || return $? ;;
      -x*) arg x sunset || return $? ;;
      --sunset\ *) larg sunset || return $? ;;
      --sunset=*) larg sunset = || return $? ;;
      # -handler*) arg -handler handler || return $? ;;
      --handler=*) args="${args#--handler=}" handler="${args%% *}" args="${args#$handler}" ;;
      -*) error "${args%% *}: Invalid argument"; return 1 ;;
      '') break ;;
      *) echo "$args: Not matched!"; break ;;
    esac
  done

  # if [[ -n "$debug" ]]
  # then
  #   printf "ACTION %s\n" "create:$create, remove:$remove, shorten:$shorten, update:$update" >&2
  #   printf "PARAM %s\n" "priv:$private, file:$file, uuid:$uuid, vanity:$vanity, sunset:$sunset" >&2
  # fi

  if [[ -z "$create$update$remove$shorten" ]]
  then error "$@: Missing action"; return 1
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

  local curl_opts="$PB_CURL_OPTS $opts"
  if [[ -n "$handler" ]]
  then url+="?$handler=1"
  # elif [[ -n "$terminal" ]]
  # then url+="?t=1"
  fi

  # echo curl ${opts[@]} $url >&2
  if [[ -n "$debug" ]]
  then echo curl $curl_opts $url
  # else curl $curl_opts $url
  fi
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
  gpg -o - -c "$file" | pbx -C # $@
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

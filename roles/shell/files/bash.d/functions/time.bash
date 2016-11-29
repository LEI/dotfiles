# Date and time utils

uz() {
  local r=${1#?} f=${1%"$r"}
  if [[ "x$f" == "x0" ]]
  then uz "$r"
  else printf "%s\n" "$1"
  fi
}

# Parse a duration string
get_seconds() {
  if [[ $# -eq 0 ]] || [[ -z "$1" ]]
  then >&2 printf "%s\n" "get_seconds: requires a value"; return 1
  elif [[ ! $1 =~ ^-?([0-9]+[smhdwMY])+$ ]]
  then >&2 printf "%s\n" "get_seconds: requires a valid duration"; return 1
  fi
  local in="$1" ou=
  local r= f=
  while [[ -n "$in" ]]
  do
    r=${in#?}
    f=${in%"$r"}
    case $f in
      Y) ou=$ou",31536000 " ;; # Year: 60 * 60 * 24 * 365
      M) ou=$ou",2592000 " ;; # Month: 60 * 60 * 24 * 30
      w) ou=$ou",604800 " ;; # week: 60 * 60 * 24 * 7
      d) ou=$ou",86400 " ;; # day: 60 * 60 * 24
      h) ou=$ou",3600 " ;; # hour: 60 * 60
      m) ou=$ou",60 " ;; # minute
      s) ou=$ou",1 " ;; # second
      *) ou=$ou$f ;;
    esac
    in=$r
  done
  local p num times seconds=0
  for p in $ou
  do
    num=$(uz "${p%,*}")
    times=${p#*,}
    # If there is no unit, default to seconds
    [[ "$times" == "$p" ]] && times=1
    seconds=$((seconds+times*num))
  done
  printf "%s\n" "$seconds"
}

# uz()(
#   r=${1#?}
#   f=${1%"$r"}
#   if [ "x$f" = "x0" ]
#   then uz "$r"
#   else printf %s\\n "$1"
#   fi
# )
# get_seconds() (
#   in=$1 ou=;
#   while [ -n "$in" ]
#   do
#     r=${in#?}
#     f=${in%"$r"}
#     case $f in
#       m) ou=$ou",60 " ;;
#       s) ou=$ou",1 " ;;
#       *) ou=$ou$f ;;
#     esac
#     in=$r
#   done
#   seconds=0
#   for p in $ou
#   do
#     num=$(uz "${p%,*}")
#     times=${p#*,}
#     seconds=$((seconds+times*num))
#   done
#   printf %s\\n "$seconds"
# )

# get_seconds() {
#   local d=${1//m/'m '}
#   d=${d//s/'s '}
#   declare -A ls=([m]=60 [s]=1)
#   local seconds=0
#   read -a d <<<"$d"
#   local i num ltr
#   for i in "${!d[@]}"
#     do num=${d[i]%%[ms]*}
#     ltr=${d[i]##*[[:digit:]]}
#     ((seconds+=num*ls[$ltr]))
#   done
#   printf "%s\n" "$seconds"
# }

# parse_duration() {
#   # shopt -s extglob
#   local str="$1"
#   # local coef=()
#   local t=0 s=0 m=0 h=0 d=0 w=0 M=0 Y=0
#   for v in s m h d w M Y
#   do
#     [[ -z "$str" ]] && break
#     local pattern="([0-9]+)$v"
#     if [[ $str =~ $pattern ]]
#     then eval $v="${BASH_REMATCH[1]}"; str="${str%${!v}$v}"
#     fi
#     # [[ -n "${!v}" ]] && [[ "${!v}" -gt 0 ]] \
#     #   && t=$((t + ${!v} * ${v_coef))
#   done
#   if [[ -n "$str" ]]
#   then error "$str: Unparsed arguments"; return 1
#   fi
#   # [[ -n "$s" ]] && [[ "$s" -gt 0 ]] && t=$((t + $s))
#   # [[ -n "$m" ]] && [[ "$m" -gt 0 ]] && t=$((t + $m * 60))
#   # [[ -n "$h" ]] && [[ "$h" -gt 0 ]] && t=$((t + $h * 60 * 60))
#   # [[ -n "$d" ]] && [[ "$d" -gt 0 ]] && t=$((t + $d * 60 * 60 * 24))
#   # [[ -n "$w" ]] && [[ "$w" -gt 0 ]] && t=$((t + $w * 60 * 60 * 24 * 7))
#   # [[ -n "$M" ]] && [[ "$M" -gt 0 ]] && t=$((t + $M * 60 * 60 * 24 * 31))
#   # [[ -n "$Y" ]] && [[ "$Y" -gt 0 ]] && t=$((t + $Y * 60 * 60 * 24 * 365))
#   printf "%d" "$t"
# }

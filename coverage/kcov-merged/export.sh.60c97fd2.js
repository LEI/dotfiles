var data = {lines:[
{"lineNum":"    1","line":"# Source files and export their assignments"},
{"lineNum":"    2","line":"# Usage: export_env \"$dir\"/*.conf"},
{"lineNum":"    3","line":"#        export_env \"$file1\" \"$file2\""},
{"lineNum":"    4","line":"export_env() {"},
{"lineNum":"    5","line":"  if [ $# -eq 0 ]; then","class":"lineCov","hits":"1","order":"226",},
{"lineNum":"    6","line":"    return 0","class":"lineCov","hits":"1","order":"223",},
{"lineNum":"    7","line":"  fi"},
{"lineNum":"    8","line":"  local _f _rc=0","class":"lineCov","hits":"1","order":"221",},
{"lineNum":"    9","line":"  set -a","class":"lineCov","hits":"1","order":"220",},
{"lineNum":"   10","line":"  for _f in \"$@\"; do","class":"lineCov","hits":"1","order":"224",},
{"lineNum":"   11","line":"    if [ -f \"$_f\" ]; then","class":"lineCov","hits":"1","order":"219",},
{"lineNum":"   12","line":"      # shellcheck disable=SC1090"},
{"lineNum":"   13","line":"      . \"$_f\" || _rc=$?","class":"lineCov","hits":"1","order":"218",},
{"lineNum":"   14","line":"    fi"},
{"lineNum":"   15","line":"  done"},
{"lineNum":"   16","line":"  set +a","class":"lineCov","hits":"1","order":"225",},
{"lineNum":"   17","line":"  return $_rc","class":"lineCov","hits":"1","order":"222",},
{"lineNum":"   18","line":"}"},
]};
var percent_low = 25;var percent_high = 75;
var header = { "command" : "", "date" : "2026-04-21 05:17:37", "instrumented" : 9, "covered" : 9,};
var merged_data = [];

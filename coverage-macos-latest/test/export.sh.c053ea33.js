var data = {lines:[
{"lineNum":"    1","line":"# Source files and export their assignments"},
{"lineNum":"    2","line":"# Usage: export_env \"$dir\"/*.conf"},
{"lineNum":"    3","line":"#        export_env \"$file1\" \"$file2\""},
{"lineNum":"    4","line":"export_env() {"},
{"lineNum":"    5","line":"  if [ $# -eq 0 ]; then","class":"lineCov","hits":"4","order":"126","possible_hits":"0",},
{"lineNum":"    6","line":"    echo >&2 \"export_env: missing arguments\"","class":"lineCov","hits":"1","order":"134","possible_hits":"0",},
{"lineNum":"    7","line":"    return 1","class":"lineCov","hits":"1","order":"135","possible_hits":"0",},
{"lineNum":"    8","line":"  fi"},
{"lineNum":"    9","line":"  local _f _rc=0","class":"lineCov","hits":"3","order":"127","possible_hits":"0",},
{"lineNum":"   10","line":"  set -a","class":"lineCov","hits":"3","order":"128","possible_hits":"0",},
{"lineNum":"   11","line":"  for _f in \"$@\"; do","class":"lineCov","hits":"3","order":"129","possible_hits":"0",},
{"lineNum":"   12","line":"    if [ -f \"$_f\" ]; then","class":"lineCov","hits":"3","order":"130","possible_hits":"0",},
{"lineNum":"   13","line":"      # shellcheck source=/dev/null"},
{"lineNum":"   14","line":"      . \"$_f\" || _rc=$?","class":"lineCov","hits":"2","order":"131","possible_hits":"0",},
{"lineNum":"   15","line":"    fi"},
{"lineNum":"   16","line":"  done"},
{"lineNum":"   17","line":"  set +a","class":"lineCov","hits":"3","order":"132","possible_hits":"0",},
{"lineNum":"   18","line":"  return $_rc","class":"lineCov","hits":"3","order":"133","possible_hits":"0",},
{"lineNum":"   19","line":"}"},
]};
var percent_low = 25;var percent_high = 75;
var header = { "command" : "test", "date" : "2026-03-31 05:46:44", "instrumented" : 10, "covered" : 10,};
var merged_data = [];

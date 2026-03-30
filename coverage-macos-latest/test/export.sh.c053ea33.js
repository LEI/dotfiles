var data = {lines:[
{"lineNum":"    1","line":"# Source files and export their assignments"},
{"lineNum":"    2","line":"# Usage: export_env \"$dir\"/*.conf"},
{"lineNum":"    3","line":"#        export_env \"$file1\" \"$file2\""},
{"lineNum":"    4","line":"export_env() {"},
{"lineNum":"    5","line":"  if [ $# -eq 0 ]; then","class":"lineCov","hits":"4","order":"21","possible_hits":"0",},
{"lineNum":"    6","line":"    echo >&2 \"export_env: missing arguments\"","class":"lineCov","hits":"1","order":"29","possible_hits":"0",},
{"lineNum":"    7","line":"    return 1","class":"lineCov","hits":"1","order":"30","possible_hits":"0",},
{"lineNum":"    8","line":"  fi"},
{"lineNum":"    9","line":"  local _f _rc=0","class":"lineCov","hits":"3","order":"22","possible_hits":"0",},
{"lineNum":"   10","line":"  set -a","class":"lineCov","hits":"3","order":"23","possible_hits":"0",},
{"lineNum":"   11","line":"  for _f in \"$@\"; do","class":"lineCov","hits":"3","order":"24","possible_hits":"0",},
{"lineNum":"   12","line":"    if [ -f \"$_f\" ]; then","class":"lineCov","hits":"3","order":"25","possible_hits":"0",},
{"lineNum":"   13","line":"      # shellcheck source=/dev/null"},
{"lineNum":"   14","line":"      . \"$_f\" || _rc=$?","class":"lineCov","hits":"2","order":"26","possible_hits":"0",},
{"lineNum":"   15","line":"    fi"},
{"lineNum":"   16","line":"  done"},
{"lineNum":"   17","line":"  set +a","class":"lineCov","hits":"3","order":"27","possible_hits":"0",},
{"lineNum":"   18","line":"  return $_rc","class":"lineCov","hits":"3","order":"28","possible_hits":"0",},
{"lineNum":"   19","line":"}"},
]};
var percent_low = 25;var percent_high = 75;
var header = { "command" : "test", "date" : "2026-03-30 06:40:18", "instrumented" : 10, "covered" : 10,};
var merged_data = [];

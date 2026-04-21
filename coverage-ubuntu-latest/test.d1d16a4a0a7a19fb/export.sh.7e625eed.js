var data = {lines:[
{"lineNum":"    1","line":"# Source files and export their assignments"},
{"lineNum":"    2","line":"# Usage: export_env \"$dir\"/*.conf"},
{"lineNum":"    3","line":"#        export_env \"$file1\" \"$file2\""},
{"lineNum":"    4","line":"export_env() {"},
{"lineNum":"    5","line":"  if [ $# -eq 0 ]; then","class":"lineCov","hits":"4","order":"160","possible_hits":"0",},
{"lineNum":"    6","line":"    return 0","class":"lineCov","hits":"1","order":"168","possible_hits":"0",},
{"lineNum":"    7","line":"  fi"},
{"lineNum":"    8","line":"  local _f _rc=0","class":"lineCov","hits":"3","order":"161","possible_hits":"0",},
{"lineNum":"    9","line":"  set -a","class":"lineCov","hits":"3","order":"162","possible_hits":"0",},
{"lineNum":"   10","line":"  for _f in \"$@\"; do","class":"lineCov","hits":"3","order":"163","possible_hits":"0",},
{"lineNum":"   11","line":"    if [ -f \"$_f\" ]; then","class":"lineCov","hits":"3","order":"164","possible_hits":"0",},
{"lineNum":"   12","line":"      # shellcheck disable=SC1090"},
{"lineNum":"   13","line":"      . \"$_f\" || _rc=$?","class":"lineCov","hits":"2","order":"165","possible_hits":"0",},
{"lineNum":"   14","line":"    fi"},
{"lineNum":"   15","line":"  done"},
{"lineNum":"   16","line":"  set +a","class":"lineCov","hits":"3","order":"166","possible_hits":"0",},
{"lineNum":"   17","line":"  return $_rc","class":"lineCov","hits":"3","order":"167","possible_hits":"0",},
{"lineNum":"   18","line":"}"},
]};
var percent_low = 25;var percent_high = 75;
var header = { "command" : "test", "date" : "2026-04-21 05:14:04", "instrumented" : 9, "covered" : 9,};
var merged_data = [];

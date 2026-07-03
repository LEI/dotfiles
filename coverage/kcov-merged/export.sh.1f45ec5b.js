var data = {lines:[
{"lineNum":"    1","line":"# shellcheck shell=sh"},
{"lineNum":"    2","line":""},
{"lineNum":"    3","line":"# Source files and export their assignments."},
{"lineNum":"    4","line":"# Files must contain bare KEY=VALUE lines (no quotes, no shell features)"},
{"lineNum":"    5","line":"# to stay portable with systemd\'s environment.d parser."},
{"lineNum":"    6","line":"# Usage: export_env \"$dir\"/*.conf"},
{"lineNum":"    7","line":"#        export_env \"$file1\" \"$file2\""},
{"lineNum":"    8","line":"export_env() {"},
{"lineNum":"    9","line":"  if [ $# -eq 0 ]; then","class":"lineCov","hits":"1","order":"160",},
{"lineNum":"   10","line":"    return 0","class":"lineCov","hits":"1","order":"158",},
{"lineNum":"   11","line":"  fi"},
{"lineNum":"   12","line":"  file=","class":"lineCov","hits":"1","order":"156",},
{"lineNum":"   13","line":"  return_code=0","class":"lineCov","hits":"1","order":"154",},
{"lineNum":"   14","line":"  set -a","class":"lineCov","hits":"1","order":"159",},
{"lineNum":"   15","line":"  for file in \"$@\"; do","class":"lineCov","hits":"1","order":"153",},
{"lineNum":"   16","line":"    if [ -f \"$file\" ]; then","class":"lineCov","hits":"1","order":"152",},
{"lineNum":"   17","line":"      # shellcheck source=/dev/null"},
{"lineNum":"   18","line":"      . \"$file\" || return_code=$?","class":"lineCov","hits":"1","order":"151",},
{"lineNum":"   19","line":"    fi"},
{"lineNum":"   20","line":"  done"},
{"lineNum":"   21","line":"  set +a","class":"lineCov","hits":"1","order":"157",},
{"lineNum":"   22","line":"  unset file","class":"lineCov","hits":"1","order":"150",},
{"lineNum":"   23","line":"  return \"$return_code\"","class":"lineCov","hits":"1","order":"155",},
{"lineNum":"   24","line":"}"},
]};
var percent_low = 25;var percent_high = 75;
var header = { "command" : "", "date" : "2026-07-03 05:19:31", "instrumented" : 11, "covered" : 11,};
var merged_data = [];

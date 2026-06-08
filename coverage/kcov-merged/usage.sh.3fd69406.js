var data = {lines:[
{"lineNum":"    1","line":"# shellcheck shell=sh"},
{"lineNum":"    2","line":""},
{"lineNum":"    3","line":"# Render --help via `usage`, with raw #USAGE spec fallback"},
{"lineNum":"    4","line":"usage_help() {"},
{"lineNum":"    5","line":"  if ! command -v usage >/dev/null; then","class":"lineCov","hits":"1","order":"444",},
{"lineNum":"    6","line":"    echo \"${0##*/}: \\`usage\\` not installed, showing raw spec\" >&2","class":"lineNoCov","hits":"0",},
{"lineNum":"    7","line":"    usage_spec","class":"lineNoCov","hits":"0",},
{"lineNum":"    8","line":"    return","class":"lineNoCov","hits":"0",},
{"lineNum":"    9","line":"  fi"},
{"lineNum":"   10","line":"  usage exec --help bash \"$0\"","class":"lineCov","hits":"1","order":"443",},
{"lineNum":"   11","line":"}"},
{"lineNum":"   12","line":""},
{"lineNum":"   13","line":"# Print #USAGE directives without the leading prefix"},
{"lineNum":"   14","line":"usage_spec() {"},
{"lineNum":"   15","line":"  grep \'^#USAGE\' \"$0\" | sed \'s/^#USAGE //\'","class":"lineCov","hits":"1","order":"442",},
{"lineNum":"   16","line":"}"},
]};
var percent_low = 25;var percent_high = 75;
var header = { "command" : "", "date" : "2026-06-08 19:00:10", "instrumented" : 6, "covered" : 3,};
var merged_data = [];

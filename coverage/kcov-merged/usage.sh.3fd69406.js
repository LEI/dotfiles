var data = {lines:[
{"lineNum":"    1","line":"# shellcheck shell=sh"},
{"lineNum":"    2","line":""},
{"lineNum":"    3","line":"# Render --help via `usage`, with raw #USAGE spec fallback"},
{"lineNum":"    4","line":"usage_help() {"},
{"lineNum":"    5","line":"  if command -v usage >/dev/null && rendered=\"$(usage exec --help bash \"$0\")\" && [ -n \"$rendered\" ]; then","class":"lineCov","hits":"1","order":"190",},
{"lineNum":"    6","line":"    printf \'%s\\n\' \"$rendered\"","class":"lineCov","hits":"1","order":"187",},
{"lineNum":"    7","line":"  else"},
{"lineNum":"    8","line":"    printf \'Usage: %s %s\\n\' \"${0##*/}\" \"${1:-}\"","class":"lineNoCov","hits":"0",},
{"lineNum":"    9","line":"  fi"},
{"lineNum":"   10","line":"  unset rendered","class":"lineCov","hits":"1","order":"189",},
{"lineNum":"   11","line":"}"},
{"lineNum":"   12","line":""},
{"lineNum":"   13","line":"# Print #USAGE directives without the leading prefix"},
{"lineNum":"   14","line":"usage_spec() {"},
{"lineNum":"   15","line":"  grep \'^#USAGE\' \"$0\" | sed \'s/^#USAGE //\'","class":"lineCov","hits":"1","order":"188",},
{"lineNum":"   16","line":"}"},
]};
var percent_low = 25;var percent_high = 75;
var header = { "command" : "", "date" : "2026-06-29 00:38:42", "instrumented" : 5, "covered" : 4,};
var merged_data = [];

var data = {lines:[
{"lineNum":"    1","line":"# shellcheck shell=sh"},
{"lineNum":"    2","line":""},
{"lineNum":"    3","line":"# Render --help via `usage`, with raw #USAGE spec fallback"},
{"lineNum":"    4","line":"usage_help() {"},
{"lineNum":"    5","line":"  if command -v usage >/dev/null && rendered=\"$(usage exec --help bash \"$0\")\" && [ -n \"$rendered\" ]; then","class":"lineCov","hits":"14","order":"316","possible_hits":"0",},
{"lineNum":"    6","line":"    printf \'%s\\n\' \"$rendered\"","class":"lineCov","hits":"2","order":"317","possible_hits":"0",},
{"lineNum":"    7","line":"  else"},
{"lineNum":"    8","line":"    printf \'Usage: %s %s\\n\' \"${0##*/}\" \"${1:-}\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"    9","line":"  fi"},
{"lineNum":"   10","line":"  unset rendered","class":"lineCov","hits":"2","order":"318","possible_hits":"0",},
{"lineNum":"   11","line":"}"},
{"lineNum":"   12","line":""},
{"lineNum":"   13","line":"# Print #USAGE directives without the leading prefix"},
{"lineNum":"   14","line":"usage_spec() {"},
{"lineNum":"   15","line":"  grep \'^#USAGE\' \"$0\" | sed \'s/^#USAGE //\'","class":"lineCov","hits":"6","order":"321","possible_hits":"0",},
{"lineNum":"   16","line":"}"},
]};
var percent_low = 25;var percent_high = 75;
var header = { "command" : "test", "date" : "2026-07-05 00:53:14", "instrumented" : 5, "covered" : 4,};
var merged_data = [];

var data = {lines:[
{"lineNum":"    1","line":"# shellcheck shell=sh"},
{"lineNum":"    2","line":""},
{"lineNum":"    3","line":"# Fail if mise version is older than the required minimum"},
{"lineNum":"    4","line":"require_mise_version() {"},
{"lineNum":"    5","line":"  min=\"$1\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"    6","line":"  ver=\"$(mise version --json | jq -r \'.version\')\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"    7","line":"  if ! printf \'%s\\n%s\\n\' \"$min\" \"$ver\" | sort -V -C; then","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"    8","line":"    die \"mise >= $min required (found ${ver:-unknown})\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"    9","line":"  fi"},
{"lineNum":"   10","line":"  unset min ver","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   11","line":"}"},
]};
var percent_low = 25;var percent_high = 75;
var header = { "command" : "test", "date" : "2026-06-29 00:38:09", "instrumented" : 5, "covered" : 0,};
var merged_data = [];

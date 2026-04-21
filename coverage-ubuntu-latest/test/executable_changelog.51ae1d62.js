var data = {lines:[
{"lineNum":"    1","line":"#!/bin/bash"},
{"lineNum":"    2","line":"# Show changes since the last git pull"},
{"lineNum":"    3","line":"#USAGE arg \"[command]\" help=\"Command to run (default: log)\" {"},
{"lineNum":"    4","line":"#USAGE   choices \"log\" \"diff\""},
{"lineNum":"    5","line":"#USAGE }"},
{"lineNum":"    6","line":""},
{"lineNum":"    7","line":"set -eu","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"    8","line":""},
{"lineNum":"    9","line":"cmd=\"${1:-}\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   10","line":"[ $# -gt 0 ] && shift","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   11","line":"newline=$\'\\n\'","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   12","line":"reflog=\"$(git reflog | grep -A1 pull | head -2 | cut -d\' \' -f1)\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   13","line":"case \"$cmd\" in","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   14","line":"  diff) git diff \"$@\" \"${reflog//$newline/..}\" ;;","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   15","line":"  *) git log --oneline \"$@\" \"${reflog//*$newline/}~1..${reflog//$newline*/}\" ;;","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   16","line":"esac"},
]};
var percent_low = 25;var percent_high = 75;
var header = { "command" : "test", "date" : "2026-04-21 05:14:04", "instrumented" : 8, "covered" : 0,};
var merged_data = [];

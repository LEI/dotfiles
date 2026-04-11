var data = {lines:[
{"lineNum":"    1","line":"#!/bin/bash"},
{"lineNum":"    2","line":""},
{"lineNum":"    3","line":"# Show changes since last pull"},
{"lineNum":"    4","line":"# Usage: changelog [diff]"},
{"lineNum":"    5","line":""},
{"lineNum":"    6","line":"set -eu","class":"lineNoCov","hits":"0",},
{"lineNum":"    7","line":""},
{"lineNum":"    8","line":"cmd=\"${1:-}\"","class":"lineNoCov","hits":"0",},
{"lineNum":"    9","line":"[ $# -gt 0 ] && shift","class":"lineNoCov","hits":"0",},
{"lineNum":"   10","line":"newline=$\'\\n\'","class":"lineNoCov","hits":"0",},
{"lineNum":"   11","line":"reflog=\"$(git reflog | grep -A1 pull | head -2 | cut -d\' \' -f1)\"","class":"lineNoCov","hits":"0",},
{"lineNum":"   12","line":"case \"$cmd\" in","class":"lineNoCov","hits":"0",},
{"lineNum":"   13","line":"  diff) git diff \"$@\" \"${reflog//$newline/..}\" ;;","class":"lineNoCov","hits":"0",},
{"lineNum":"   14","line":"  *) git log --oneline \"${reflog//*$newline/}~1..${reflog//$newline*/}\" ;;","class":"lineNoCov","hits":"0",},
{"lineNum":"   15","line":"esac"},
]};
var percent_low = 25;var percent_high = 75;
var header = { "command" : "", "date" : "2026-04-11 02:06:05", "instrumented" : 8, "covered" : 0,};
var merged_data = [];

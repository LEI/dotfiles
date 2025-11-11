var data = {lines:[
{"lineNum":"    1","line":"#!/bin/sh"},
{"lineNum":"    2","line":""},
{"lineNum":"    3","line":"set -eu","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"    4","line":""},
{"lineNum":"    5","line":"if [ -n \"${TMUX:-}\" ]; then","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"    6","line":"  # Send C-m twice to ensure \'!!\' is expanded"},
{"lineNum":"    7","line":"  tmux send-keys -t:.! \'!!\' C-m C-m","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"    8","line":"else"},
{"lineNum":"    9","line":"  echo >&2 \"Unknown environment\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   10","line":"  exit 1","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   11","line":"fi"},
]};
var percent_low = 25;var percent_high = 75;
var header = { "command" : "test", "date" : "2025-11-11 23:22:02", "instrumented" : 5, "covered" : 0,};
var merged_data = [];

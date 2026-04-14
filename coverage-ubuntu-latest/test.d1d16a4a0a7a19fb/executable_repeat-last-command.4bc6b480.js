var data = {lines:[
{"lineNum":"    1","line":"#!/bin/sh"},
{"lineNum":"    2","line":"# Re-execute the last command in tmux"},
{"lineNum":"    3","line":""},
{"lineNum":"    4","line":"set -eu","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"    5","line":""},
{"lineNum":"    6","line":"if [ -n \"${TMUX:-}\" ]; then","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"    7","line":"  # Send C-m twice to ensure \'!!\' is expanded"},
{"lineNum":"    8","line":"  tmux send-keys -t:.! \'!!\' C-m C-m","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"    9","line":"else"},
{"lineNum":"   10","line":"  echo \"Unknown environment\" >&2","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   11","line":"  exit 1","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   12","line":"fi"},
]};
var percent_low = 25;var percent_high = 75;
var header = { "command" : "test", "date" : "2026-04-14 06:18:32", "instrumented" : 5, "covered" : 0,};
var merged_data = [];

var data = {lines:[
{"lineNum":"    1","line":"#!/bin/sh"},
{"lineNum":"    2","line":""},
{"lineNum":"    3","line":"# Re-execute the last command in tmux"},
{"lineNum":"    4","line":""},
{"lineNum":"    5","line":"set -eu","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"    6","line":""},
{"lineNum":"    7","line":"if [ -n \"${TMUX:-}\" ]; then","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"    8","line":"  # Send C-m twice to ensure \'!!\' is expanded"},
{"lineNum":"    9","line":"  tmux send-keys -t:.! \'!!\' C-m C-m","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   10","line":"else"},
{"lineNum":"   11","line":"  echo \"Unknown environment\" >&2","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   12","line":"  exit 1","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   13","line":"fi"},
]};
var percent_low = 25;var percent_high = 75;
var header = { "command" : "test", "date" : "2026-04-21 05:14:04", "instrumented" : 5, "covered" : 0,};
var merged_data = [];

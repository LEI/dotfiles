var data = {lines:[
{"lineNum":"    1","line":"#!/bin/sh"},
{"lineNum":"    2","line":""},
{"lineNum":"    3","line":"# Attach to an existing session or create a new session"},
{"lineNum":"    4","line":""},
{"lineNum":"    5","line":"set -eu","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"    6","line":""},
{"lineNum":"    7","line":"export TERM=tmux-256color","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"    8","line":""},
{"lineNum":"    9","line":"if [ $# -ne 0 ]; then","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   10","line":"  if [ \"$*\" = \"-u NONE\" ]; then","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   11","line":"    set -- -f/dev/null -Ltmp # lsk","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   12","line":"  fi"},
{"lineNum":"   13","line":"  if [ \"$1\" = current-config ]; then","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   14","line":"    tmux -Lfoo -f/dev/null start\\; show -g","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   15","line":"  elif [ \"$1\" = default-config ]; then","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   16","line":"    tmux -Lfoo -f/dev/null start\\; show -gw","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   17","line":"  else"},
{"lineNum":"   18","line":"    tmux \"$@\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   19","line":"  fi"},
{"lineNum":"   20","line":"elif [ -n \"${TMUX:-}\" ]; then","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   21","line":"  tmux ls","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   22","line":"else"},
{"lineNum":"   23","line":"  tmux attach || tmux new-session","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   24","line":"fi"},
]};
var percent_low = 25;var percent_high = 75;
var header = { "command" : "test", "date" : "2025-11-11 23:28:41", "instrumented" : 13, "covered" : 0,};
var merged_data = [];

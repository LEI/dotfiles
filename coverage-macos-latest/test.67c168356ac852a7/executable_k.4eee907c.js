var data = {lines:[
{"lineNum":"    1","line":"#!/bin/sh"},
{"lineNum":"    2","line":"# kubectl wrapper with colorized output"},
{"lineNum":"    3","line":""},
{"lineNum":"    4","line":"set -eu","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"    5","line":""},
{"lineNum":"    6","line":"if [ -z \"${KUBECTL_COMMAND:-}\" ]; then","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"    7","line":"  if command -v kubecolor >/dev/null; then","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"    8","line":"    KUBECTL_COMMAND=kubecolor","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"    9","line":"  else"},
{"lineNum":"   10","line":"    KUBECTL_COMMAND=kubectl","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   11","line":"  fi"},
{"lineNum":"   12","line":"fi"},
{"lineNum":"   13","line":""},
{"lineNum":"   14","line":"if [ $# -eq 0 ]; then","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   15","line":"  # $KUBECTL_COMMAND cluster-info"},
{"lineNum":"   16","line":"  set -- config get-contexts","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   17","line":"fi"},
{"lineNum":"   18","line":"$KUBECTL_COMMAND \"$@\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
]};
var percent_low = 25;var percent_high = 75;
var header = { "command" : "test", "date" : "2026-04-14 06:21:50", "instrumented" : 8, "covered" : 0,};
var merged_data = [];

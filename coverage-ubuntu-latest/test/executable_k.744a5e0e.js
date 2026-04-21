var data = {lines:[
{"lineNum":"    1","line":"#!/bin/sh"},
{"lineNum":"    2","line":""},
{"lineNum":"    3","line":"# kubectl wrapper with colorized output"},
{"lineNum":"    4","line":""},
{"lineNum":"    5","line":"set -eu","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"    6","line":""},
{"lineNum":"    7","line":"if [ -z \"${KUBECTL_COMMAND:-}\" ]; then","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"    8","line":"  if command -v kubecolor >/dev/null; then","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"    9","line":"    KUBECTL_COMMAND=kubecolor","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   10","line":"  else"},
{"lineNum":"   11","line":"    KUBECTL_COMMAND=kubectl","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   12","line":"  fi"},
{"lineNum":"   13","line":"fi"},
{"lineNum":"   14","line":""},
{"lineNum":"   15","line":"if [ $# -eq 0 ]; then","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   16","line":"  # $KUBECTL_COMMAND cluster-info"},
{"lineNum":"   17","line":"  set -- config get-contexts","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   18","line":"fi"},
{"lineNum":"   19","line":"$KUBECTL_COMMAND \"$@\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
]};
var percent_low = 25;var percent_high = 75;
var header = { "command" : "test", "date" : "2026-04-21 05:14:04", "instrumented" : 8, "covered" : 0,};
var merged_data = [];

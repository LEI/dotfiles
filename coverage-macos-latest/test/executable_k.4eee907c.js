var data = {lines:[
{"lineNum":"    1","line":"#!/bin/sh"},
{"lineNum":"    2","line":""},
{"lineNum":"    3","line":"set -eu","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"    4","line":""},
{"lineNum":"    5","line":"if [ -z \"${KUBECTL_COMMAND:-}\" ]; then","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"    6","line":"  if command -v kubecolor >/dev/null; then","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"    7","line":"    KUBECTL_COMMAND=kubecolor","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"    8","line":"  else"},
{"lineNum":"    9","line":"    KUBECTL_COMMAND=kubectl","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   10","line":"  fi"},
{"lineNum":"   11","line":"fi"},
{"lineNum":"   12","line":""},
{"lineNum":"   13","line":"if [ $# -eq 0 ]; then","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   14","line":"  # $KUBECTL_COMMAND cluster-info"},
{"lineNum":"   15","line":"  set -- config get-contexts","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   16","line":"fi"},
{"lineNum":"   17","line":"$KUBECTL_COMMAND \"$@\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
]};
var percent_low = 25;var percent_high = 75;
var header = { "command" : "test", "date" : "2025-11-11 20:19:29", "instrumented" : 8, "covered" : 0,};
var merged_data = [];

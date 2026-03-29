var data = {lines:[
{"lineNum":"    1","line":"{{- if or .features.docker .features.podman -}}","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"    2","line":"#!/bin/sh"},
{"lineNum":"    3","line":"# Run docker/podman compose for a project directory"},
{"lineNum":"    4","line":""},
{"lineNum":"    5","line":"set -eu","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"    6","line":""},
{"lineNum":"    7","line":"dir=\"${1:?dir required}\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"    8","line":"shift","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"    9","line":""},
{"lineNum":"   10","line":"provider=\"${CONTAINER_PROVIDER:?}\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   11","line":""},
{"lineNum":"   12","line":"compose() {"},
{"lineNum":"   13","line":"  echo >&2 \"$provider compose --project-directory=$dir $*\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   14","line":"  $provider compose --project-directory=\"$dir\" \"$@\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   15","line":"}"},
{"lineNum":"   16","line":""},
{"lineNum":"   17","line":"# Default: start services then tail logs"},
{"lineNum":"   18","line":"if [ $# -eq 0 ]; then","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   19","line":"  compose up --build --detach","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   20","line":"  set -- logs --follow --since=1m","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   21","line":"fi"},
{"lineNum":"   22","line":""},
{"lineNum":"   23","line":"compose \"$@\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   24","line":"{{ end -}}","class":"lineNoCov","hits":"0","possible_hits":"0",},
]};
var percent_low = 25;var percent_high = 75;
var header = { "command" : "test", "date" : "2026-03-29 08:39:50", "instrumented" : 12, "covered" : 0,};
var merged_data = [];

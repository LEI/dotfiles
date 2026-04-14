var data = {lines:[
{"lineNum":"    1","line":"#!/bin/sh"},
{"lineNum":"    2","line":"# Open editor with stdin or specified files"},
{"lineNum":"    3","line":""},
{"lineNum":"    4","line":"set -eu","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"    5","line":""},
{"lineNum":"    6","line":"editor=\"${VISUAL:-${EDITOR:-/usr/bin/editor}}\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"    7","line":""},
{"lineNum":"    8","line":"if [ -z \"$editor\" ]; then","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"    9","line":"  printf >&2 \'%s\\n\' \"EDITOR and VISUAL are empty or not set\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   10","line":"  return 1","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   11","line":"fi"},
{"lineNum":"   12","line":""},
{"lineNum":"   13","line":"if [ $# -ne 0 ]; then","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   14","line":"  $editor \"$@\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   15","line":"elif [ ! -t 0 ]; then","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   16","line":"  $editor -","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   17","line":"else"},
{"lineNum":"   18","line":"  $editor .","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   19","line":"fi"},
]};
var percent_low = 25;var percent_high = 75;
var header = { "command" : "test", "date" : "2026-04-14 06:21:50", "instrumented" : 10, "covered" : 0,};
var merged_data = [];

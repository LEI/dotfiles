var data = {lines:[
{"lineNum":"    1","line":"#!/bin/sh"},
{"lineNum":"    2","line":""},
{"lineNum":"    3","line":"set -eu","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"    4","line":""},
{"lineNum":"    5","line":"editor=\"${VISUAL:-${EDITOR:-/usr/bin/editor}}\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"    6","line":""},
{"lineNum":"    7","line":"if [ -z \"$editor\" ]; then","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"    8","line":"  printf >&2 \'%s\\n\' \"EDITOR and VISUAL are empty or not set\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"    9","line":"  return 1","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   10","line":"fi"},
{"lineNum":"   11","line":""},
{"lineNum":"   12","line":"if [ $# -ne 0 ]; then","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   13","line":"  $editor \"$@\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   14","line":"elif [ ! -t 0 ]; then","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   15","line":"  $editor -","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   16","line":"else"},
{"lineNum":"   17","line":"  $editor .","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   18","line":"fi"},
]};
var percent_low = 25;var percent_high = 75;
var header = { "command" : "test", "date" : "2025-11-12 03:10:25", "instrumented" : 10, "covered" : 0,};
var merged_data = [];

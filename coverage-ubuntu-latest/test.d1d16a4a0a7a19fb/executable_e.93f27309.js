var data = {lines:[
{"lineNum":"    1","line":"#!/bin/sh"},
{"lineNum":"    2","line":"# Open editor with stdin or specified files"},
{"lineNum":"    3","line":"#USAGE arg \"[files]...\" help=\"Files to open in editor\""},
{"lineNum":"    4","line":""},
{"lineNum":"    5","line":"set -eu","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"    6","line":""},
{"lineNum":"    7","line":"editor=\"${VISUAL:-${EDITOR:-/usr/bin/editor}}\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"    8","line":""},
{"lineNum":"    9","line":"if [ -z \"$editor\" ]; then","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   10","line":"  printf >&2 \'%s\\n\' \"EDITOR and VISUAL are empty or not set\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   11","line":"  return 1","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   12","line":"fi"},
{"lineNum":"   13","line":""},
{"lineNum":"   14","line":"if [ $# -ne 0 ]; then","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   15","line":"  $editor \"$@\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   16","line":"elif [ ! -t 0 ]; then","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   17","line":"  $editor -","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   18","line":"else"},
{"lineNum":"   19","line":"  $editor .","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   20","line":"fi"},
]};
var percent_low = 25;var percent_high = 75;
var header = { "command" : "test", "date" : "2026-04-21 05:14:04", "instrumented" : 10, "covered" : 0,};
var merged_data = [];

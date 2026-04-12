var data = {lines:[
{"lineNum":"    1","line":"#!/usr/bin/env bash"},
{"lineNum":"    2","line":"#MISE description=\"Check for blank lines at start/end and consecutive\""},
{"lineNum":"    3","line":""},
{"lineNum":"    4","line":"set -euo pipefail","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"    5","line":""},
{"lineNum":"    6","line":"if ((BASH_VERSINFO[0] < 4)); then","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"    7","line":"  echo >&2 \"bash 4+ required, found $BASH_VERSION\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"    8","line":"  exit 1","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"    9","line":"fi"},
{"lineNum":"   10","line":""},
{"lineNum":"   11","line":"script_dir=\"$(cd \"$(dirname \"$0\")\" && pwd)\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   12","line":""},
{"lineNum":"   13","line":"if [ $# -eq 0 ]; then","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   14","line":"  mapfile -t files < <(git ls-files -z | tr \'\\0\' \'\\n\')","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   15","line":"  set -- \"${files[@]}\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   16","line":"fi"},
{"lineNum":"   17","line":""},
{"lineNum":"   18","line":"if [ $# -eq 0 ]; then","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   19","line":"  echo >&2 \"no files to validate\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   20","line":"  exit 0","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   21","line":"fi"},
{"lineNum":"   22","line":""},
{"lineNum":"   23","line":"awk -f \"$script_dir/validate-blank.awk\" \"$@\" >&2","class":"lineNoCov","hits":"0","possible_hits":"0",},
]};
var percent_low = 25;var percent_high = 75;
var header = { "command" : "test", "date" : "2026-04-12 07:36:48", "instrumented" : 12, "covered" : 0,};
var merged_data = [];

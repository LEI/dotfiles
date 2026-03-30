var data = {lines:[
{"lineNum":"    1","line":"#!/bin/sh"},
{"lineNum":"    2","line":"#MISE description=\"Show per-component shell init timing via SHELL_BENCH\""},
{"lineNum":"    3","line":"#USAGE arg \"[shell]\" help=\"Shell to benchmark (default: current shell)\" {"},
{"lineNum":"    4","line":"#USAGE   choices \"bash\" \"zsh\""},
{"lineNum":"    5","line":"#USAGE }"},
{"lineNum":"    6","line":""},
{"lineNum":"    7","line":"set -eu","class":"lineNoCov","hits":"0",},
{"lineNum":"    8","line":""},
{"lineNum":"    9","line":"shell=\"${1:-${SHELL##*/}}\"","class":"lineNoCov","hits":"0",},
{"lineNum":"   10","line":""},
{"lineNum":"   11","line":"case \"$shell\" in","class":"lineNoCov","hits":"0",},
{"lineNum":"   12","line":"  bash|zsh)"},
{"lineNum":"   13","line":"    SHELL_BENCH=true \"$shell\" -ic exit","class":"lineNoCov","hits":"0",},
{"lineNum":"   14","line":"    ;;"},
{"lineNum":"   15","line":"  *)"},
{"lineNum":"   16","line":"    echo >&2 \"bench: invalid shell \'$shell\', expected bash or zsh\"","class":"lineNoCov","hits":"0",},
{"lineNum":"   17","line":"    exit 2","class":"lineNoCov","hits":"0",},
{"lineNum":"   18","line":"    ;;"},
{"lineNum":"   19","line":"esac"},
]};
var percent_low = 25;var percent_high = 75;
var header = { "command" : "", "date" : "2026-03-30 06:27:09", "instrumented" : 6, "covered" : 0,};
var merged_data = [];

var data = {lines:[
{"lineNum":"    1","line":"#!/bin/bash"},
{"lineNum":"    2","line":"# Connect to SSH host in a specific directory"},
{"lineNum":"    3","line":"#USAGE arg \"<host>\" help=\"SSH host\""},
{"lineNum":"    4","line":"#USAGE arg \"<dir>\" help=\"Remote directory\""},
{"lineNum":"    5","line":"#USAGE arg \"[command]...\" help=\"Command to run (default: interactive shell)\""},
{"lineNum":"    6","line":"# host() { ssh-cd host /var/www/app; }"},
{"lineNum":"    7","line":"# host-logs() { ssh-cd host /var/log \'tail -f *.log\' | tspin; }"},
{"lineNum":"    8","line":"host=\"${1:?host required}\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"    9","line":"dir=\"${2:?dir required}\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   10","line":"shift 2","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   11","line":"qdir=$(printf \'%q\' \"$dir\")","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   12","line":"if [ $# -eq 0 ]; then","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   13","line":"  set -- \"exec \\$SHELL -l\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   14","line":"fi"},
{"lineNum":"   15","line":"ssh -t \"$host\" \"cd $qdir && $*\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
]};
var percent_low = 25;var percent_high = 75;
var header = { "command" : "test", "date" : "2026-04-21 05:14:04", "instrumented" : 7, "covered" : 0,};
var merged_data = [];

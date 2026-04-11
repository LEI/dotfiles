var data = {lines:[
{"lineNum":"    1","line":"#!/bin/bash"},
{"lineNum":"    2","line":"# host() { ssh-cd host /var/www/app; }"},
{"lineNum":"    3","line":"# host-logs() { ssh-cd host /var/log \'tail -f *.log\' | tspin; }"},
{"lineNum":"    4","line":"host=\"${1:?host required}\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"    5","line":"dir=\"${2:?dir required}\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"    6","line":"shift 2","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"    7","line":"qdir=$(printf \'%q\' \"$dir\")","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"    8","line":"if [ $# -eq 0 ]; then","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"    9","line":"  set -- \"exec \\$SHELL -l\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   10","line":"fi"},
{"lineNum":"   11","line":"ssh -t \"$host\" \"cd $qdir && $*\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
]};
var percent_low = 25;var percent_high = 75;
var header = { "command" : "test", "date" : "2026-04-11 02:05:41", "instrumented" : 7, "covered" : 0,};
var merged_data = [];

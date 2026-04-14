var data = {lines:[
{"lineNum":"    1","line":"#!/bin/sh"},
{"lineNum":"    2","line":"# Select and attach to a shpool session"},
{"lineNum":"    3","line":""},
{"lineNum":"    4","line":"set -eu","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"    5","line":""},
{"lineNum":"    6","line":"# if [ $# -ne 2 ] ; then"},
{"lineNum":"    7","line":"#   echo \"usage: shpool-ssh <remote-machine> <session-name>\" >&2"},
{"lineNum":"    8","line":"#   return 1"},
{"lineNum":"    9","line":"# fi"},
{"lineNum":"   10","line":"# ssh -t \"-oRemoteCommand=shpool attach -f $2\" \"$1\""},
{"lineNum":"   11","line":""},
{"lineNum":"   12","line":"bind=\"ctrl-x:execute(shpool detach \'{}\' && echo \'Detached session: {}\')+refresh-preview,ctrl-q:execute(shpool kill \'{}\' && echo \'Killed session: {}\' >&2)+refresh-cmd\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   13","line":"cmd=\"shpool list | tail -n+2 | tr \'\\t\' \' \' | cut -d\' \' -f1\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   14","line":"preview=\"shpool list | tr \'\\t\' \' \' | grep \'^{} \'\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   15","line":"name=\"$(sk --bind=\"$bind\" --cmd=\"$cmd\" --preview=\"$preview\" --preview-window=down:2)\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   16","line":""},
{"lineNum":"   17","line":"if [ -z \"$name\" ]; then","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   18","line":"  exit 1","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   19","line":"fi"},
{"lineNum":"   20","line":""},
{"lineNum":"   21","line":"# FIXME: $SHELL -c \'cd $PWD; $SHELL\'"},
{"lineNum":"   22","line":"shpool attach --cmd=\"$SHELL\" \"$name\" \"$@\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
]};
var percent_low = 25;var percent_high = 75;
var header = { "command" : "test", "date" : "2026-04-14 06:21:50", "instrumented" : 8, "covered" : 0,};
var merged_data = [];

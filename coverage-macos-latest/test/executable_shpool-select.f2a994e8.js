var data = {lines:[
{"lineNum":"    1","line":"#!/bin/sh"},
{"lineNum":"    2","line":""},
{"lineNum":"    3","line":"set -eu","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"    4","line":""},
{"lineNum":"    5","line":"# if [ $# -ne 2 ] ; then"},
{"lineNum":"    6","line":"#   echo \"usage: shpool-ssh <remote-machine> <session-name>\" >&2"},
{"lineNum":"    7","line":"#   return 1"},
{"lineNum":"    8","line":"# fi"},
{"lineNum":"    9","line":"# ssh -t \"-oRemoteCommand=shpool attach -f $2\" \"$1\""},
{"lineNum":"   10","line":""},
{"lineNum":"   11","line":"bind=\"ctrl-x:execute(shpool detach \'{}\' && echo >&2 \'Detached session: {}\')+refresh-preview,ctrl-q:execute(shpool kill \'{}\' && echo >&2 \'Killed session: {}\')+refresh-cmd\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   12","line":"cmd=\"shpool list | tail -n+2 | tr \'\\t\' \' \' | cut -d\' \' -f1\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   13","line":"preview=\"shpool list | tr \'\\t\' \' \' | grep \'^{} \'\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   14","line":"name=\"$(sk --bind=\"$bind\" --cmd=\"$cmd\" --preview=\"$preview\" --preview-window=down:2)\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   15","line":""},
{"lineNum":"   16","line":"if [ -z \"$name\" ]; then","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   17","line":"  exit 1","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   18","line":"fi"},
{"lineNum":"   19","line":""},
{"lineNum":"   20","line":"# FIXME: $SHELL -c \'cd $PWD; $SHELL\'"},
{"lineNum":"   21","line":"shpool attach --cmd=\"$SHELL\" \"$name\" \"$@\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
]};
var percent_low = 25;var percent_high = 75;
var header = { "command" : "test", "date" : "2025-11-12 00:57:42", "instrumented" : 8, "covered" : 0,};
var merged_data = [];

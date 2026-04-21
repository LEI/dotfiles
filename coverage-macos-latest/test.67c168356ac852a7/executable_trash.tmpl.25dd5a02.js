var data = {lines:[
{"lineNum":"    1","line":"{{- if eq .os \"linux\" -}}","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"    2","line":"#!/bin/sh"},
{"lineNum":"    3","line":"#MISE description=\"Move files to trash\""},
{"lineNum":"    4","line":"#USAGE arg \"<file>...\" help=\"Files to trash\""},
{"lineNum":"    5","line":""},
{"lineNum":"    6","line":"set -eu","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"    7","line":"{{- if lookPath \"gtrash\" | isExecutable }}","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"    8","line":"exec gtrash put \"$@\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"    9","line":"{{- else if lookPath \"trash-put\" | isExecutable }}","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   10","line":"exec trash-put \"$@\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   11","line":"{{- else if lookPath \"gio\" | isExecutable }}","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   12","line":"exec gio trash \"$@\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   13","line":"{{- else }}","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   14","line":"printf \'trash: no trash tool found\\n\' >&2","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   15","line":"exit 1","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   16","line":"{{- end }}","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   17","line":"{{ end -}}","class":"lineNoCov","hits":"0","possible_hits":"0",},
]};
var percent_low = 25;var percent_high = 75;
var header = { "command" : "test", "date" : "2026-04-21 05:17:05", "instrumented" : 13, "covered" : 0,};
var merged_data = [];

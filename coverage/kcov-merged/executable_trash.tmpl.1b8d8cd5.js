var data = {lines:[
{"lineNum":"    1","line":"{{- if eq .os \"linux\" -}}","class":"lineNoCov","hits":"0",},
{"lineNum":"    2","line":"#!/bin/sh"},
{"lineNum":"    3","line":"set -eu","class":"lineNoCov","hits":"0",},
{"lineNum":"    4","line":"{{- if lookPath \"gtrash\" | isExecutable }}","class":"lineNoCov","hits":"0",},
{"lineNum":"    5","line":"exec gtrash put \"$@\"","class":"lineNoCov","hits":"0",},
{"lineNum":"    6","line":"{{- else if lookPath \"trash-put\" | isExecutable }}","class":"lineNoCov","hits":"0",},
{"lineNum":"    7","line":"exec trash-put \"$@\"","class":"lineNoCov","hits":"0",},
{"lineNum":"    8","line":"{{- else if lookPath \"gio\" | isExecutable }}","class":"lineNoCov","hits":"0",},
{"lineNum":"    9","line":"exec gio trash \"$@\"","class":"lineNoCov","hits":"0",},
{"lineNum":"   10","line":"{{- else }}","class":"lineNoCov","hits":"0",},
{"lineNum":"   11","line":"printf \'trash: no trash tool found\\n\' >&2","class":"lineNoCov","hits":"0",},
{"lineNum":"   12","line":"exit 1","class":"lineNoCov","hits":"0",},
{"lineNum":"   13","line":"{{- end }}","class":"lineNoCov","hits":"0",},
{"lineNum":"   14","line":"{{ end -}}","class":"lineNoCov","hits":"0",},
]};
var percent_low = 25;var percent_high = 75;
var header = { "command" : "", "date" : "2026-03-31 05:47:13", "instrumented" : 13, "covered" : 0,};
var merged_data = [];

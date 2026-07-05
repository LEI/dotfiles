var data = {lines:[
{"lineNum":"    1","line":"# shellcheck shell=sh"},
{"lineNum":"    2","line":""},
{"lineNum":"    3","line":"# Clamp value between min and max"},
{"lineNum":"    4","line":"clamp() {"},
{"lineNum":"    5","line":"  value=\"$1\"","class":"lineCov","hits":"1","order":"323",},
{"lineNum":"    6","line":"  min=\"${2:-1}\"","class":"lineCov","hits":"1","order":"321",},
{"lineNum":"    7","line":"  max=\"${3:-32}\"","class":"lineCov","hits":"1","order":"320",},
{"lineNum":"    8","line":""},
{"lineNum":"    9","line":"  if [ \"$value\" -lt \"$min\" ]; then","class":"lineCov","hits":"1","order":"319",},
{"lineNum":"   10","line":"    printf \'%d\\n\' \"$min\"","class":"lineCov","hits":"1","order":"322",},
{"lineNum":"   11","line":"  elif [ \"$value\" -gt \"$max\" ]; then","class":"lineCov","hits":"1","order":"318",},
{"lineNum":"   12","line":"    printf \'%d\\n\' \"$max\"","class":"lineCov","hits":"1","order":"317",},
{"lineNum":"   13","line":"  else"},
{"lineNum":"   14","line":"    printf \'%d\\n\' \"$value\"","class":"lineCov","hits":"1","order":"316",},
{"lineNum":"   15","line":"  fi"},
{"lineNum":"   16","line":"}"},
]};
var percent_low = 25;var percent_high = 75;
var header = { "command" : "", "date" : "2026-07-05 00:54:19", "instrumented" : 8, "covered" : 8,};
var merged_data = [];

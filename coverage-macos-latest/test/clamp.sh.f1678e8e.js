var data = {lines:[
{"lineNum":"    1","line":"# shellcheck shell=sh"},
{"lineNum":"    2","line":""},
{"lineNum":"    3","line":"# Clamp value between min and max"},
{"lineNum":"    4","line":"clamp() {"},
{"lineNum":"    5","line":"  value=\"$1\"","class":"lineCov","hits":"37","order":"148","possible_hits":"0",},
{"lineNum":"    6","line":"  min=\"${2:-1}\"","class":"lineCov","hits":"37","order":"149","possible_hits":"0",},
{"lineNum":"    7","line":"  max=\"${3:-32}\"","class":"lineCov","hits":"37","order":"150","possible_hits":"0",},
{"lineNum":"    8","line":""},
{"lineNum":"    9","line":"  if [ \"$value\" -lt \"$min\" ]; then","class":"lineCov","hits":"37","order":"151","possible_hits":"0",},
{"lineNum":"   10","line":"    printf \'%d\\n\' \"$min\"","class":"lineCov","hits":"2","order":"154","possible_hits":"0",},
{"lineNum":"   11","line":"  elif [ \"$value\" -gt \"$max\" ]; then","class":"lineCov","hits":"35","order":"152","possible_hits":"0",},
{"lineNum":"   12","line":"    printf \'%d\\n\' \"$max\"","class":"lineCov","hits":"10","order":"155","possible_hits":"0",},
{"lineNum":"   13","line":"  else"},
{"lineNum":"   14","line":"    printf \'%d\\n\' \"$value\"","class":"lineCov","hits":"25","order":"153","possible_hits":"0",},
{"lineNum":"   15","line":"  fi"},
{"lineNum":"   16","line":"}"},
]};
var percent_low = 25;var percent_high = 75;
var header = { "command" : "test", "date" : "2026-07-05 00:38:19", "instrumented" : 8, "covered" : 8,};
var merged_data = [];

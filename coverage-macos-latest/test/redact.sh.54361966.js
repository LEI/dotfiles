var data = {lines:[
{"lineNum":"    1","line":"# shellcheck shell=sh"},
{"lineNum":"    2","line":""},
{"lineNum":"    3","line":"# Mask the value of NAME=value args whose name ends in a secret keyword"},
{"lineNum":"    4","line":"redact_arg() {"},
{"lineNum":"    5","line":"  case $1 in","class":"lineCov","hits":"106","order":"170","possible_hits":"0",},
{"lineNum":"    6","line":"  *TOKEN=?* | *SECRET=?* | *PASSWORD=?* | *PASS=?* | *PRIVATE_KEY=?*)"},
{"lineNum":"    7","line":"    printf \'%s=[REDACTED]\' \"${1%%=*}\"","class":"lineCov","hits":"5","order":"171","possible_hits":"0",},
{"lineNum":"    8","line":"    ;;"},
{"lineNum":"    9","line":"  *)"},
{"lineNum":"   10","line":"    printf \'%s\' \"$1\"","class":"lineCov","hits":"101","order":"172","possible_hits":"0",},
{"lineNum":"   11","line":"    ;;"},
{"lineNum":"   12","line":"  esac"},
{"lineNum":"   13","line":"}"},
]};
var percent_low = 25;var percent_high = 75;
var header = { "command" : "test", "date" : "2026-07-05 00:53:14", "instrumented" : 3, "covered" : 3,};
var merged_data = [];

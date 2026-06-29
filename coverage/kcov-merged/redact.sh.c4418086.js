var data = {lines:[
{"lineNum":"    1","line":"# shellcheck shell=sh"},
{"lineNum":"    2","line":""},
{"lineNum":"    3","line":"# Mask the value of NAME=value args whose name ends in a secret keyword"},
{"lineNum":"    4","line":"redact_arg() {"},
{"lineNum":"    5","line":"  case $1 in","class":"lineCov","hits":"1","order":"505",},
{"lineNum":"    6","line":"  *TOKEN=?* | *SECRET=?* | *PASSWORD=?* | *PASS=?* | *PRIVATE_KEY=?*)"},
{"lineNum":"    7","line":"    printf \'%s=[REDACTED]\' \"${1%%=*}\"","class":"lineCov","hits":"1","order":"503",},
{"lineNum":"    8","line":"    ;;"},
{"lineNum":"    9","line":"  *)"},
{"lineNum":"   10","line":"    printf \'%s\' \"$1\"","class":"lineCov","hits":"1","order":"504",},
{"lineNum":"   11","line":"    ;;"},
{"lineNum":"   12","line":"  esac"},
{"lineNum":"   13","line":"}"},
]};
var percent_low = 25;var percent_high = 75;
var header = { "command" : "", "date" : "2026-06-29 00:38:42", "instrumented" : 3, "covered" : 3,};
var merged_data = [];

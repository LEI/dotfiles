var data = {lines:[
{"lineNum":"    1","line":"# shellcheck shell=sh"},
{"lineNum":"    2","line":""},
{"lineNum":"    3","line":"# Read a secret from the OS keystore"},
{"lineNum":"    4","line":"# Usage: keystore_get SERVICE ACCOUNT"},
{"lineNum":"    5","line":"keystore_get() {"},
{"lineNum":"    6","line":"  service=$1","class":"lineNoCov","hits":"0",},
{"lineNum":"    7","line":"  account=$2","class":"lineNoCov","hits":"0",},
{"lineNum":"    8","line":"{{- if eq .os \"darwin\" }}","class":"lineNoCov","hits":"0",},
{"lineNum":"    9","line":"  if ! command -v security >/dev/null 2>&1; then","class":"lineNoCov","hits":"0",},
{"lineNum":"   10","line":"    echo \"keystore_get: security not found, cannot read $service/$account\" >&2","class":"lineNoCov","hits":"0",},
{"lineNum":"   11","line":"    return 1","class":"lineNoCov","hits":"0",},
{"lineNum":"   12","line":"  fi"},
{"lineNum":"   13","line":"  security find-generic-password -s \"$service\" -a \"$account\" -w 2>/dev/null","class":"lineNoCov","hits":"0",},
{"lineNum":"   14","line":"{{- else }}","class":"lineNoCov","hits":"0",},
{"lineNum":"   15","line":"  if ! command -v secret-tool >/dev/null 2>&1; then","class":"lineNoCov","hits":"0",},
{"lineNum":"   16","line":"    echo \"keystore_get: secret-tool not found, cannot read $service/$account\" >&2","class":"lineNoCov","hits":"0",},
{"lineNum":"   17","line":"    return 1","class":"lineNoCov","hits":"0",},
{"lineNum":"   18","line":"  fi"},
{"lineNum":"   19","line":"  secret-tool lookup service \"$service\" account \"$account\" 2>/dev/null","class":"lineNoCov","hits":"0",},
{"lineNum":"   20","line":"{{- end }}","class":"lineNoCov","hits":"0",},
{"lineNum":"   21","line":"}"},
]};
var percent_low = 25;var percent_high = 75;
var header = { "command" : "", "date" : "2026-07-05 00:54:19", "instrumented" : 13, "covered" : 0,};
var merged_data = [];

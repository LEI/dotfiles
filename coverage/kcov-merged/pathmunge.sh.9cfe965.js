var data = {lines:[
{"lineNum":"    1","line":"pathmunge() {"},
{"lineNum":"    2","line":"  if [ -z \"$1\" ] || [ ! -d \"$1\" ]; then","class":"lineCov","hits":"1","order":"202",},
{"lineNum":"    3","line":"    return 1","class":"lineCov","hits":"1","order":"198",},
{"lineNum":"    4","line":"  fi"},
{"lineNum":"    5","line":"  # Skip if already in PATH (unless replacing)"},
{"lineNum":"    6","line":"  # Not required with ZSH typeset -U path"},
{"lineNum":"    7","line":"  case \":$PATH:\" in","class":"lineCov","hits":"1","order":"200",},
{"lineNum":"    8","line":"  *:\"$1\":*)"},
{"lineNum":"    9","line":"    if [ \"${2:-}\" = replace ]; then","class":"lineCov","hits":"1","order":"197",},
{"lineNum":"   10","line":"      PATH=\"${PATH//:$1/}\"","class":"lineCov","hits":"1","order":"195",},
{"lineNum":"   11","line":"      PATH=\"${PATH//$1:/}\"","class":"lineCov","hits":"1","order":"194",},
{"lineNum":"   12","line":"    else"},
{"lineNum":"   13","line":"      return 2","class":"lineCov","hits":"1","order":"201",},
{"lineNum":"   14","line":"    fi"},
{"lineNum":"   15","line":"    ;;"},
{"lineNum":"   16","line":"  esac"},
{"lineNum":"   17","line":"  if [ \"${2:-}\" = after ]; then","class":"lineCov","hits":"1","order":"193",},
{"lineNum":"   18","line":"    PATH=\"$PATH:$1\"","class":"lineCov","hits":"1","order":"199",},
{"lineNum":"   19","line":"  else"},
{"lineNum":"   20","line":"    PATH=\"$1:$PATH\"","class":"lineCov","hits":"1","order":"196",},
{"lineNum":"   21","line":"  fi"},
{"lineNum":"   22","line":"}"},
]};
var percent_low = 25;var percent_high = 75;
var header = { "command" : "", "date" : "2026-04-11 02:19:44", "instrumented" : 10, "covered" : 10,};
var merged_data = [];

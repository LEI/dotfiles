var data = {lines:[
{"lineNum":"    1","line":"pathmunge() {"},
{"lineNum":"    2","line":"  if [ -z \"$1\" ] || [ ! -d \"$1\" ]; then","class":"lineCov","hits":"26","order":"40","possible_hits":"0",},
{"lineNum":"    3","line":"    return 1","class":"lineCov","hits":"3","order":"49","possible_hits":"0",},
{"lineNum":"    4","line":"  fi"},
{"lineNum":"    5","line":"  # Skip if already in PATH (unless replacing)"},
{"lineNum":"    6","line":"  # Not required with ZSH typeset -U path"},
{"lineNum":"    7","line":"  case \":$PATH:\" in","class":"lineCov","hits":"11","order":"41","possible_hits":"0",},
{"lineNum":"    8","line":"  *:\"$1\":*)"},
{"lineNum":"    9","line":"    if [ \"${2:-}\" = replace ]; then","class":"lineCov","hits":"3","order":"45","possible_hits":"0",},
{"lineNum":"   10","line":"      PATH=\"${PATH//:$1/}\"","class":"lineCov","hits":"2","order":"47","possible_hits":"0",},
{"lineNum":"   11","line":"      PATH=\"${PATH//$1:/}\"","class":"lineCov","hits":"2","order":"48","possible_hits":"0",},
{"lineNum":"   12","line":"    else"},
{"lineNum":"   13","line":"      return 2","class":"lineCov","hits":"1","order":"46","possible_hits":"0",},
{"lineNum":"   14","line":"    fi"},
{"lineNum":"   15","line":"    ;;"},
{"lineNum":"   16","line":"  esac"},
{"lineNum":"   17","line":"  if [ \"${2:-}\" = after ]; then","class":"lineCov","hits":"10","order":"42","possible_hits":"0",},
{"lineNum":"   18","line":"    PATH=\"$PATH:$1\"","class":"lineCov","hits":"4","order":"44","possible_hits":"0",},
{"lineNum":"   19","line":"  else"},
{"lineNum":"   20","line":"    PATH=\"$1:$PATH\"","class":"lineCov","hits":"6","order":"43","possible_hits":"0",},
{"lineNum":"   21","line":"  fi"},
{"lineNum":"   22","line":"}"},
]};
var percent_low = 25;var percent_high = 75;
var header = { "command" : "test", "date" : "2026-03-29 08:37:32", "instrumented" : 10, "covered" : 10,};
var merged_data = [];

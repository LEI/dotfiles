var data = {lines:[
{"lineNum":"    1","line":"#!/bin/sh"},
{"lineNum":"    2","line":""},
{"lineNum":"    3","line":"# NOTE: after install-packages.sh (system)"},
{"lineNum":"    4","line":""},
{"lineNum":"    5","line":"set -eu","class":"lineCov","hits":"1","order":"114","possible_hits":"0",},
{"lineNum":"    6","line":""},
{"lineNum":"    7","line":". \"$CHEZMOI_WORKING_TREE/home/.chezmoitemplates/helpers.sh\"","class":"lineCov","hits":"1","order":"115","possible_hits":"0",},
{"lineNum":"    8","line":""},
{"lineNum":"    9","line":"pip_packages=\"\"","class":"lineCov","hits":"1","order":"116","possible_hits":"0",},
{"lineNum":"   10","line":"if [ -n \"$pip_packages\" ]; then","class":"lineCov","hits":"1","order":"117","possible_hits":"0",},
{"lineNum":"   11","line":"  python=python","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   12","line":"  if ! has python && has python3; then","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   13","line":"    python=python3","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   14","line":"  fi"},
{"lineNum":"   15","line":"  dry_run $python -m pip install --user --quiet $pip_packages","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   16","line":"fi"},
{"lineNum":"   17","line":""},
{"lineNum":"   18","line":"# https://github.com/astral-sh/uv/issues/13750"},
{"lineNum":"   19","line":"# run uv tool install --quiet $uv_packages"},
{"lineNum":"   20","line":"msg \"Already installed: recoverpy\"","class":"lineCov","hits":"1","order":"118","possible_hits":"0",},
{"lineNum":"   21","line":"msg \"Already installed: yamllint\"","class":"lineCov","hits":"1","order":"119","possible_hits":"0",},
]};
var percent_low = 25;var percent_high = 75;
var header = { "command" : "test", "date" : "2026-03-31 06:19:03", "instrumented" : 10, "covered" : 6,};
var merged_data = [];

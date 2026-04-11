var data = {lines:[
{"lineNum":"    1","line":"#!/bin/sh"},
{"lineNum":"    2","line":""},
{"lineNum":"    3","line":"set -eu","class":"lineCov","hits":"1","order":"101","possible_hits":"0",},
{"lineNum":"    4","line":""},
{"lineNum":"    5","line":". \"$CHEZMOI_WORKING_TREE/home/.chezmoitemplates/helpers.sh\"","class":"lineCov","hits":"1","order":"102","possible_hits":"0",},
{"lineNum":"    6","line":""},
{"lineNum":"    7","line":"# XDG vars inlined at template render time (target may not exist yet)"},
{"lineNum":"    8","line":"# XDG base directory defaults"},
{"lineNum":"    9","line":"XDG_CACHE_HOME=${XDG_CACHE_HOME:-$HOME/.cache}","class":"lineCov","hits":"1","order":"103","possible_hits":"0",},
{"lineNum":"   10","line":"XDG_CONFIG_HOME=${XDG_CONFIG_HOME:-$HOME/.config}","class":"lineCov","hits":"1","order":"104","possible_hits":"0",},
{"lineNum":"   11","line":"XDG_DATA_HOME=${XDG_DATA_HOME:-$HOME/.local/share}","class":"lineCov","hits":"1","order":"105","possible_hits":"0",},
{"lineNum":"   12","line":"XDG_STATE_HOME=${XDG_STATE_HOME:-$HOME/.local/state}","class":"lineCov","hits":"1","order":"106","possible_hits":"0",},
{"lineNum":"   13","line":"# Config path redirects: tools that don\'t follow XDG by default, alphabetical by var name"},
{"lineNum":"   14","line":"CURL_HOME=$XDG_CONFIG_HOME/curl","class":"lineCov","hits":"1","order":"107","possible_hits":"0",},
{"lineNum":"   15","line":"INPUTRC=$XDG_CONFIG_HOME/readline/inputrc","class":"lineCov","hits":"1","order":"108","possible_hits":"0",},
{"lineNum":"   16","line":"LESSHISTFILE=$XDG_STATE_HOME/less/history","class":"lineCov","hits":"1","order":"109","possible_hits":"0",},
{"lineNum":"   17","line":"LG_CONFIG_FILE=$XDG_CONFIG_HOME/lazygit/theme.yml,$XDG_CONFIG_HOME/lazygit/config.yml","class":"lineCov","hits":"1","order":"110","possible_hits":"0",},
{"lineNum":"   18","line":"RIPGREP_CONFIG_PATH=$XDG_CONFIG_HOME/ripgrep/config","class":"lineCov","hits":"1","order":"111","possible_hits":"0",},
{"lineNum":"   19","line":"STARSHIP_CONFIG=$XDG_CONFIG_HOME/starship/starship.toml","class":"lineCov","hits":"1","order":"112","possible_hits":"0",},
{"lineNum":"   20","line":"WGETRC=$XDG_CONFIG_HOME/wget/wgetrc","class":"lineCov","hits":"1","order":"113","possible_hits":"0",},
]};
var percent_low = 25;var percent_high = 75;
var header = { "command" : "test", "date" : "2026-04-11 02:19:11", "instrumented" : 13, "covered" : 13,};
var merged_data = [];

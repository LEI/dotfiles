var data = {lines:[
{"lineNum":"    1","line":"#!/bin/sh"},
{"lineNum":"    2","line":"#MISE description=\"\'mise update\' or \'mise run update\'\""},
{"lineNum":"    3","line":""},
{"lineNum":"    4","line":"set -eux","class":"lineCov","hits":"1","order":"245","possible_hits":"0",},
{"lineNum":"    5","line":""},
{"lineNum":"    6","line":"# if [ \"$(nvim --headless -u NONE \"+echo has(\'nvim-0.8\')\" +qa 2>&1)\" = 1 ]; then"},
{"lineNum":"    7","line":"# timeout 5m nvim --headless +LazyUpdate! +qa # >/dev/null"},
{"lineNum":"    8","line":"if chezmoi feature neovim; then","class":"lineCov","hits":"1","order":"246","possible_hits":"0",},
{"lineNum":"    9","line":"  timeout 5m nvim --headless try \\| +LazyUpdate! \\| +quitall \\| catch \\| +cquitall \\| end","class":"lineCov","hits":"1","order":"247","possible_hits":"0",},
{"lineNum":"   10","line":"  # echo"},
{"lineNum":"   11","line":"fi"},
{"lineNum":"   12","line":""},
{"lineNum":"   13","line":"# export TMUX_PLUGIN_MANAGER_PATH=\"$HOME/.config/tmux/plugins/\""},
{"lineNum":"   14","line":"if chezmoi feature tmux; then","class":"lineCov","hits":"1","order":"248","possible_hits":"0",},
{"lineNum":"   15","line":"  timeout 5m ~/.config/tmux/plugins/tpm/bin/update_plugins all","class":"lineCov","hits":"1","order":"249","possible_hits":"0",},
{"lineNum":"   16","line":"fi"},
]};
var percent_low = 25;var percent_high = 75;
var header = { "command" : "test", "date" : "2025-11-12 00:33:55", "instrumented" : 5, "covered" : 5,};
var merged_data = [];

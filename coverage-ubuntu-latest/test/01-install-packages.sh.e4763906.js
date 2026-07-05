var data = {lines:[
{"lineNum":"    1","line":"#!/bin/sh"},
{"lineNum":"    2","line":""},
{"lineNum":"    3","line":"# https://www.chezmoi.io/user-guide/advanced/install-packages-declaratively/"},
{"lineNum":"    4","line":""},
{"lineNum":"    5","line":"set -eu","class":"lineCov","hits":"1","order":"114","possible_hits":"0",},
{"lineNum":"    6","line":""},
{"lineNum":"    7","line":"lib_dir=\"$CHEZMOI_WORKING_TREE/home/dot_local/lib\"","class":"lineCov","hits":"1","order":"115","possible_hits":"0",},
{"lineNum":"    8","line":"# shellcheck source=home/dot_local/lib/sh/log.sh"},
{"lineNum":"    9","line":". \"$lib_dir/sh/log.sh\"","class":"lineCov","hits":"1","order":"116","possible_hits":"0",},
{"lineNum":"   10","line":"# shellcheck source=home/dot_local/lib/sh/run.sh"},
{"lineNum":"   11","line":". \"$lib_dir/sh/run.sh\"","class":"lineCov","hits":"1","order":"119","possible_hits":"0",},
{"lineNum":"   12","line":""},
{"lineNum":"   13","line":"packages=\"apt-utils bash bash-completion build-essential ca-certificates coreutils curl direnv git git-extras git-filter-repo libssl-dev openssh-client parallel pipx pkg-config procps python3 python3-venv ripgrep time trash-cli tree unzip util-linux wget zoxide zsh\"","class":"lineCov","hits":"1","order":"120","possible_hits":"0",},
{"lineNum":"   14","line":"msg \"Installing apt packages: $packages\"","class":"lineCov","hits":"1","order":"121","possible_hits":"0",},
{"lineNum":"   15","line":""},
{"lineNum":"   16","line":"dry_run sudo dpkg --configure -a","class":"lineCov","hits":"1","order":"123","possible_hits":"0",},
{"lineNum":"   17","line":""},
{"lineNum":"   18","line":"dry_run sudo -E apt-get update --quiet # >/dev/null","class":"lineCov","hits":"1","order":"129","possible_hits":"0",},
{"lineNum":"   19","line":""},
{"lineNum":"   20","line":"# shellcheck disable=SC2086"},
{"lineNum":"   21","line":"dry_run sudo -E apt-get install --quiet --yes $packages # >/dev/null","class":"lineCov","hits":"1","order":"130","possible_hits":"0",},
{"lineNum":"   22","line":""},
{"lineNum":"   23","line":"msg \"Installed apt packages\"","class":"lineCov","hits":"1","order":"131","possible_hits":"0",},
]};
var percent_low = 25;var percent_high = 75;
var header = { "command" : "test", "date" : "2026-07-05 00:53:52", "instrumented" : 10, "covered" : 10,};
var merged_data = [];

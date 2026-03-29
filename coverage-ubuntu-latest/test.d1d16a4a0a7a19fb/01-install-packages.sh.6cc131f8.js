var data = {lines:[
{"lineNum":"    1","line":"#!/bin/sh"},
{"lineNum":"    2","line":""},
{"lineNum":"    3","line":"# https://www.chezmoi.io/user-guide/advanced/install-packages-declaratively/"},
{"lineNum":"    4","line":""},
{"lineNum":"    5","line":"set -eu","class":"lineCov","hits":"1","order":"77","possible_hits":"0",},
{"lineNum":"    6","line":""},
{"lineNum":"    7","line":". \"$CHEZMOI_WORKING_TREE/home/.chezmoitemplates/helpers.sh\"","class":"lineCov","hits":"1","order":"78","possible_hits":"0",},
{"lineNum":"    8","line":""},
{"lineNum":"    9","line":"packages=\"7zip apt-utils bash bash-completion bat build-essential ca-certificates coreutils curl direnv eza fzf git jq libssl-dev openssh-client parallel pkg-config procps ripgrep time tree unzip util-linux wget yq zoxide\"","class":"lineCov","hits":"1","order":"79","possible_hits":"0",},
{"lineNum":"   10","line":"echo >&2 \"Installing apt packages: $packages\"","class":"lineCov","hits":"1","order":"80","possible_hits":"0",},
{"lineNum":"   11","line":""},
{"lineNum":"   12","line":"# https://manpages.ubuntu.com/manpages/trusty/en/man7/debconf.7.html#frontends"},
{"lineNum":"   13","line":"# export DEBIAN_FRONTEND=noninteractive"},
{"lineNum":"   14","line":""},
{"lineNum":"   15","line":"cmd sudo -E apt-get update --quiet # >/dev/null","class":"lineCov","hits":"1","order":"81","possible_hits":"0",},
{"lineNum":"   16","line":""},
{"lineNum":"   17","line":"# shellcheck disable=SC2086"},
{"lineNum":"   18","line":"cmd sudo -E apt-get install --quiet --yes $packages # >/dev/null","class":"lineCov","hits":"1","order":"82","possible_hits":"0",},
{"lineNum":"   19","line":""},
{"lineNum":"   20","line":"echo >&2 \"Installed apt packages\"","class":"lineCov","hits":"1","order":"83","possible_hits":"0",},
]};
var percent_low = 25;var percent_high = 75;
var header = { "command" : "test", "date" : "2025-11-11 07:13:25", "instrumented" : 7, "covered" : 7,};
var merged_data = [];

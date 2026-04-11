var data = {lines:[
{"lineNum":"    1","line":"#!/bin/sh"},
{"lineNum":"    2","line":""},
{"lineNum":"    3","line":"# https://www.chezmoi.io/user-guide/advanced/install-packages-declaratively/"},
{"lineNum":"    4","line":""},
{"lineNum":"    5","line":"set -eu","class":"lineCov","hits":"1","order":"89","possible_hits":"0",},
{"lineNum":"    6","line":""},
{"lineNum":"    7","line":". \"$CHEZMOI_WORKING_TREE/home/.chezmoitemplates/helpers.sh\"","class":"lineCov","hits":"1","order":"90","possible_hits":"0",},
{"lineNum":"    8","line":""},
{"lineNum":"    9","line":"packages=\"apt-utils bash bash-completion build-essential ca-certificates coreutils curl direnv git git-absorb git-extras git-filter-repo jq libssl-dev openssh-client parallel pipx pkg-config procps python3 python3-venv ripgrep time tree unzip util-linux wget yq zoxide\"","class":"lineCov","hits":"1","order":"91","possible_hits":"0",},
{"lineNum":"   10","line":"msg \"Installing apt packages: $packages\"","class":"lineCov","hits":"1","order":"92","possible_hits":"0",},
{"lineNum":"   11","line":""},
{"lineNum":"   12","line":"# https://manpages.ubuntu.com/manpages/trusty/en/man7/debconf.7.html#frontends"},
{"lineNum":"   13","line":"# export DEBIAN_FRONTEND=noninteractive"},
{"lineNum":"   14","line":""},
{"lineNum":"   15","line":"dry_run sudo -E apt-get update --quiet # >/dev/null","class":"lineCov","hits":"1","order":"93","possible_hits":"0",},
{"lineNum":"   16","line":""},
{"lineNum":"   17","line":"# shellcheck disable=SC2086"},
{"lineNum":"   18","line":"dry_run sudo -E apt-get install --quiet --yes $packages # >/dev/null","class":"lineCov","hits":"1","order":"94","possible_hits":"0",},
{"lineNum":"   19","line":""},
{"lineNum":"   20","line":"msg \"Installed apt packages\"","class":"lineCov","hits":"1","order":"95","possible_hits":"0",},
]};
var percent_low = 25;var percent_high = 75;
var header = { "command" : "test", "date" : "2026-04-11 02:03:54", "instrumented" : 7, "covered" : 7,};
var merged_data = [];

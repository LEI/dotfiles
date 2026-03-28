#!/bin/sh
#MISE description="Run atuin doctor"

set -eu

atuin doctor | tail -n+7 | jq --compact-output

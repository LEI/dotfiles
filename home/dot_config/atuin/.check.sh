#!/bin/sh
set -eu

atuin doctor | tail -n+7 | jq --compact-output

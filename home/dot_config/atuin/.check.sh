#!/bin/bash

set -euo pipefail

atuin doctor | tail -n+7 | yq --colors --prettyPrint | sed -r '/^\s*$/d'

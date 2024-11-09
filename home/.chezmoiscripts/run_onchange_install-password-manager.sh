#!/bin/sh

# https://www.chezmoi.io/user-guide/advanced/install-your-password-manager-on-init/

set -eux

# # exit immediately if password-manager-binary is already in $PATH
# type password-manager-binary >/dev/null 2>&1 && exit

# case "$(uname -s)" in
# Darwin)
#   # commands to install password-manager-binary on Darwin
#   ;;
# Linux)
#   # commands to install password-manager-binary on Linux
#   ;;
# *)
#   echo "unsupported OS"
#   exit 1
#   ;;
# esac

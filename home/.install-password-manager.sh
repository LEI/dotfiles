#!/bin/sh

# NOTE: requires curl, sudo and unzip
# https://bitwarden.com/help/secrets-manager-cli/

set -eu

case "$CHEZMOI_COMMAND" in
init | apply | update) ;;
*) exit ;;
esac

# exit immediately if bws is already in $PATH
# type bws >/dev/null 2>&1 && exit
if command -v bws >/dev/null || [ -x ~/.local/bin/bws ]; then
  # echo "Already installed" >&2
  exit
fi

# shellcheck source=/dev/null
. "$CHEZMOI_WORKING_TREE/home/.chezmoitemplates/helpers.sh"

if [ -z "${USER:-}" ]; then
  USER="$(id -un)"
fi

echo "OSID: $OSID" >&2

if [ "$USER" = root ] && ! command -v sudo >/dev/null; then
  case "$OSID" in
  alpine)
    run apk update --quiet
    run apk add --quiet sudo
    ;;
  android | debian)
    # export DEBIAN_FRONTEND=noninteractive
    run apt-get update --quiet >/dev/null
    run apt-get install --quiet --yes sudo >/dev/null
    ;;
  arch | *)
    echo "Skipping password manager: sudo must be installed (chezmoi $CHEZMOI_COMMAND)" >&2
    exit
    ;;
  esac
fi

# Setup bws requirements (unzip)
OS="$(uname -s)"
case "$OS" in
Darwin)
  OS=apple-darwin
  # export NONINTERACTIVE=1
  # run brew install --quiet unzip
  ;;
Linux)
  # https://github.com/bitwarden/sdk-sm/issues/1218
  # https://community.bitwarden.com/t/add-x86_64-unknown-linux-musl-release-to-bws-cli/57379/3
  # Runtime musl detection: check for musl dynamic linker (works without CHEZMOI_LIBC env var)
  if [ -e /lib/ld-musl-x86_64.so.1 ] || [ -e /lib64/ld-musl-x86_64.so.1 ]; then
    echo "Skipping password manager on musl-based distro" >&2
    exit 0
  fi
  OS=unknown-linux-gnu
  case "$OSID" in
  alpine)
    run sudo apk add --quiet unzip
    ;;
  arch)
    run sudo pacman --sync --needed --noconfirm --quiet unzip
    ;;
  debian)
    # export DEBIAN_FRONTEND=noninteractive
    # run sudo -E apt-get install --quiet --yes unzip >/dev/null
    run sudo apt-get install --quiet --yes unzip # >/dev/null
    ;;
  esac
  ;;
*)
  echo "Unsupported OS: $OS" >&2
  exit 1
  ;;
esac

ARCH="$(uname -m)"
case "$ARCH" in
amd64 | x86_64) ARCH=x86_64 ;;
arm64 | aarch64) ARCH=aarch64 ;;
*)
  echo "Unsupported architecture: $ARCH" >&2
  exit 1
  ;;
esac

VERSION="$(get_release bitwarden/sdk-sm)"
VERSION="${VERSION##*-}" # dotnet-v1.0.0 -> v1.0.0

NAME="bws-$ARCH-$OS-${VERSION#v}.zip"
URL="https://github.com/bitwarden/sdk-sm/releases/download/bws-$VERSION/$NAME"

install_zip "$URL" bws

#!/bin/sh

# NOTE: requires curl, sudo and unzip
# https://bitwarden.com/help/secrets-manager-cli/

set -eu

case "${CHEZMOI_COMMAND:-}" in
apply | init | update) ;;
*) ;;
esac

. "$CHEZMOI_WORKING_TREE/home/.chezmoitemplates/helpers.sh"

if ! command -v sudo >/dev/null; then
  # NOTE: must be root
  case "$OSID" in
  alpine)
    cmd apk update --quiet
    cmd apk add --quiet sudo
    ;;
  android | debian)
    cmd apt-get update --quiet >/dev/null
    cmd apt-get install --quiet --yes sudo >/dev/null
    ;;
  arch | *)
    echo >&2 "Skipping password manager: sudo must be installed"
    exit
    ;;
  esac
fi

# exit immediately if bws is already in $PATH
# type bws >/dev/null 2>&1 && exit
if command -v bws >/dev/null || [ -f ~/.local/bin/bws ]; then
  # echo >&2 "Already installed: bws"
  exit
fi

# Determine OS and setup bws requirements (unzip)
case "$(uname -s)" in
Darwin)
  OS=apple-darwin
  export NONINTERACTIVE=1
  cmd brew install --quiet unzip
  ;;
Linux)
  # FIXME: alpine musl
  # https://github.com/bitwarden/sdk-sm/issues/1218
  # https://community.bitwarden.com/t/add-x86-64-unknown-linux-musl-release-to-bws-cli/57379/3
  if musl; then
    # echo >&2 "Building from source"
    # sudo apk add --quiet curl cargo openssl-dev pkgconfig
    # URL="https://github.com/bitwarden/sdk-sm/archive/refs/tags/bws-v$VERSION.tar.gz"
    # curl -LSfs "$URL" | tar xzf - -C "$TMPDIR"
    # cd "$TMPDIR/sdk-sm-bws-v$VERSION/"
    # export OPENSSL_NO_VENDOR=Y
    # cargo build -r --bin bws --quiet
    echo >&2 "Skipping password manager on $CHEZMOI_ARCH"
    exit 0
  fi
  OS=unknown-linux-gnu
  case "$OSID" in
  alpine)
    cmd sudo apk add --quiet unzip
    ;;
  arch)
    cmd sudo pacman --sync --needed --noconfirm --quiet unzip
    ;;
  debian)
    export DEBIAN_FRONTEND=noninteractive
    cmd sudo -E apt-get install --quiet --yes unzip >/dev/null
    ;;
  esac
  ;;
*)
  echo >&2 "Unsupported OS"
  exit 1
  ;;
esac

VERSION="$(get_release bitwarden/sdk-sm)"
VERSION="${VERSION##*-}" # dotnet-v1.0.0 -> v1.0.0

ARCH="$(uname -m)"
NAME="bws-$ARCH-$OS-${VERSION#v}.zip"
URL="https://github.com/bitwarden/sdk-sm/releases/download/bws-$VERSION/$NAME"

install_zip "$URL" bws

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
  # echo >&2 "Already installed"
  exit
fi

. "$CHEZMOI_WORKING_TREE/home/.chezmoitemplates/helpers.sh"

if [ -z "${USER:-}" ]; then
  USER="$(id --user --name)"
fi

echo >&2 "OSID: $OSID"

if [ "$USER" = root ] && ! command -v sudo >/dev/null; then
  case "$OSID" in
  alpine)
    cmd apk update --quiet
    cmd apk add --quiet sudo
    ;;
  android | debian)
    # export DEBIAN_FRONTEND=noninteractive
    cmd apt-get update --quiet >/dev/null
    cmd apt-get install --quiet --yes sudo >/dev/null
    ;;
  arch | *)
    echo >&2 "Skipping password manager: sudo must be installed (chezmoi $CHEZMOI_COMMAND)"
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
  # cmd brew install --quiet unzip
  ;;
Linux)
  # FIXME: alpine musl
  # https://github.com/bitwarden/sdk-sm/issues/1218
  # https://community.bitwarden.com/t/add-x86-64-unknown-linux-musl-release-to-bws-cli/57379/3
  if ! command -v ldd >/dev/null || grep -Fq musl "$(which ldd)"; then
    # echo >&2 "Building from source"
    # sudo apk add --quiet curl cargo openssl-dev pkgconfig
    # URL="https://github.com/bitwarden/sdk-sm/archive/refs/tags/bws-v$VERSION.tar.gz"
    # curl -LSfs "$URL" | tar xzf - -C "$TMPDIR"
    # cd "$TMPDIR/sdk-sm-bws-v$VERSION/"
    # export OPENSSL_NO_VENDOR=Y
    # cargo build -r --bin bws --quiet
    echo >&2 "Skipping password manager on $OS $CHEZMOI_ARCH (chezmoi $CHEZMOI_COMMAND)"
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
    # export DEBIAN_FRONTEND=noninteractive
    # cmd sudo -E apt-get install --quiet --yes unzip >/dev/null
    cmd sudo apt-get install --quiet --yes unzip # >/dev/null
    ;;
  esac
  ;;
*)
  echo >&2 "Unsupported OS: $OS"
  exit 1
  ;;
esac

ARCH="$(uname -m)"
case "$ARCH" in
amd64 | x86_64) ARCH=x86_64 ;;
arm64 | aarch64) ARCH=aarch64 ;;
*)
  echo >&2 "Unsupported architecture: $ARCH"
  exit 1
  ;;
esac

VERSION="$(get_release bitwarden/sdk-sm)"
VERSION="${VERSION##*-}" # dotnet-v1.0.0 -> v1.0.0

NAME="bws-$ARCH-$OS-${VERSION#v}.zip"
URL="https://github.com/bitwarden/sdk-sm/releases/download/bws-$VERSION/$NAME"

install_zip "$URL" bws

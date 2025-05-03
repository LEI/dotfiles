#!/bin/sh

# NOTE: requires curl, sudo and unzip
# https://bitwarden.com/help/secrets-manager-cli/

set -eu

# exit immediately if bws is already in $PATH
# type bws >/dev/null 2>&1 && exit
if command -v bws >/dev/null; then
  # echo >&2 'Already installed password managed: bws'
  exit
fi

BIN=/usr/local/bin/bws # "$HOME/.local/bin/bws"
VERSION=1.0.0

case "$(uname -s)" in
Darwin)
  OS=apple-darwin
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
    echo >&2 "Skipping bws"
    exit 0
  fi
  OS=unknown-linux-gnu
  ;;
*)
  echo >&2 "Unsupported OS"
  exit 1
  ;;
esac

ARCH="$(uname -m)"
NAME="bws-$ARCH-$OS-$VERSION.zip"
URL="https://github.com/bitwarden/sdk-sm/releases/download/bws-v$VERSION/$NAME"
OUT="$TMPDIR/$NAME"

set -x

# curl -LSsf "$URL" | tar xJf - -C "$TMPDIR"
curl -LSfs "$URL" -o "$OUT"
unzip -o "$OUT" -d "$TMPDIR"
sudo mv "$TMPDIR/bws" "$BIN"

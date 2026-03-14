#!/bin/sh
# Shared preamble for chezmoi scripts

# Collapsed OS identifier: id_like or id or os, android for termux
OSID="${CHEZMOI_OS_RELEASE_ID_LIKE:-${CHEZMOI_OS_RELEASE_ID:-${CHEZMOI_OS:-}}}"
if [ "$OSID" = linux ] && [ "$HOME" = /data/data/com.termux/files/home ]; then
  OSID=android
fi

# Check if value is truthy (1 or true)
truthy() {
  case "$1" in
  1|true) return 0 ;;
  *) return 1 ;;
  esac
}

# Enable shell trace when CHEZMOI_TRACE is set (custom)
truthy "${CHEZMOI_TRACE:-}" && set -x

# Check if command exists in PATH
has() {
  command -v "$@" >/dev/null 2>&1
}

# Print message to stderr
msg() {
  echo >&2 "$@"
}

# Print warning to stderr with script name
warn() {
  msg "WARN: ${0##*/}: $*"
}

# Print error to stderr with script name and exit 1
err() {
  msg "ERR: ${0##*/}: $*"
  exit 1
}

# Log command to stderr when verbose, then execute
# CHEZMOI_VERBOSE is set to 1 by chezmoi --verbose (native)
run() {
  truthy "${CHEZMOI_VERBOSE:-}" && msg "$*"
  "$@"
}

# Like run but skip execution in dry run mode
# DRY_RUN is a custom env var for test harness safety
dry_run() {
  if truthy "${DRY_RUN:-}"; then
    msg "DRY-RUN: $*"
    return 0
  fi
  run "$@"
}

# Resolve latest release tag from GitHub
get_release() {
  repo="$1"
  host="${2:-github.com}"
  tag="${3:-latest}"
  url="https://$host/$repo/releases/$tag"
  msg "Resolving $repo release ($tag)"
  # shellcheck disable=SC1083
  redirect_url="$(run curl -s -w %{redirect_url} "$url")"
  version="${redirect_url##*/}"
  if [ -z "$version" ]; then
    err "invalid tag for URL: $url"
  elif [ "$version" = "Not Found" ]; then
    err "invalid URL: $url"
  fi
  msg "Resolved $repo $version"
  echo "$version"
}

# Download and extract a release archive and install binary
install_archive() {
  extract_type="$1"
  url="$2"
  bin="$3"
  archive="${url##*/}"
  name="${4:-${bin##*/}}"
  dir="${5:-${TMPDIR:-/tmp}}"
  out="$dir/$archive"
  bindir="$HOME/.local/bin"

  if [ ! -d "$bindir" ]; then
    msg "Creating $bindir"
    run mkdir -p "$bindir"
  fi

  msg "Downloading $name"
  run curl -LSfs "$url" -o "$out"
  msg "Extracting $archive"
  case "$extract_type" in
  tar.gz) run tar -xzf "$out" -C "$dir" ;;
  zip) run unzip -o "$out" -d "$dir" ;;
  *) err "unknown archive type: $extract_type" ;;
  esac
  run chmod +x "$dir/$bin"
  msg "Installing $name to $bindir"
  run mv "$dir/$bin" "$bindir/$name"
}

install_tar_gz() {
  install_archive tar.gz "$@"
}

install_zip() {
  install_archive zip "$@"
}

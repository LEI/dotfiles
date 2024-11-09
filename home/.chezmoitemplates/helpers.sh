#!/bin/sh

OSID="${CHEZMOI_OS_RELEASE_ID_LIKE:-${CHEZMOI_OS_RELEASE_ID:-$CHEZMOI_OS}}"
if [ "$OSID" = linux ] && [ "$HOME" = /data/data/com.termux/files/home ]; then
  OSID=android
fi

cmd() {
  log "$@"
  "$@"
}

err() {
  log "ERR: $*"
  exit 1
}

log() {
  echo >&2 "$@"
}

get_release() {
  repo="$1"
  host="${2:-}"
  alias="${3:-}"
  get_github_release "$repo" "$host" "$alias"
}

get_github_release() {
  repo="$1"
  host="${2:-github.com}"
  alias="${3:-latest}"
  url="https://$host/$repo/releases/$alias"
  # shellcheck disable=SC1083
  redirect_url="$(curl -s -w %{redirect_url} "$url")"
  tag="${redirect_url##*/}"
  if [ "$tag" = "" ]; then
    log "Invalid tag for URL: $url"
    return 1
  elif [ "$tag" = "Not Found" ]; then
    log "Invalid URL: $url"
    return 1
  fi
  echo "$tag"
}

install_archive() {
  format="$1"
  url="$2"
  bin="$3" # Path to the extracted executable relative to TMDIR

  archive="${2##*/}"
  name="${4:-${bin##*/}}"
  out="$TMPDIR/$archive"

  bindir="$HOME/.local/bin"
  if [ ! -d "$bindir" ]; then
    log "Creating directory: $bindir"
    mkdir -p "$bindir"
  fi

  # set -x

  log "Downloading: $url"
  curl -LSfs "$url" -o "$out"
  log "Extracting: $out"
  # shellcheck disable=SC2059
  eval "$(printf "$format" "$out" "$TMPDIR")"
  log "Executable: $TMPDIR/$bin"
  chmod +x "$TMPDIR/$bin"
  log "Moving to: $bindir/$name"
  mv "$TMPDIR/$bin" "$bindir/$name"
}

install_tar_gz() {
  install_archive 'tar -xzf "%s" -C "%s"' "$@"
}

install_zip() {
  install_archive 'unzip -o "%s" -d "%s"' "$@"
}

musl() {
  ! command -v ldd >/dev/null || grep -Fq musl "$(which ldd)"
}

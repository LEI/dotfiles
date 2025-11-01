#!/bin/sh

# https://github.com/zyedidia/eget
# https://github.com/devmatteini/dra
# https://github.com/marwanhawari/stew
# https://github.com/redraw/gh-install/blob/main/gh-install

OSID="${CHEZMOI_OS_RELEASE_ID_LIKE:-${CHEZMOI_OS_RELEASE_ID:-${CHEZMOI_OS:-}}}"
if [ "$OSID" = linux ] && [ "$HOME" = /data/data/com.termux/files/home ]; then
  OSID=android
fi

cmd() {
  msg "$@"
  "$@"
}
run() {
  msg "$@"
  "$@"
}
dry_run() {
  if [ "${DRY_RUN:-}" = true ]; then
    msg "DRY-RUN: $*"
    return
  fi
  run "$@"
}

err() {
  msg "ERR: $*"
  exit 1
}

msg() {
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
    echo >&2 "Invalid tag for URL: $url"
    return 1
  elif [ "$tag" = "Not Found" ]; then
    echo >&2 "Invalid URL: $url"
    return 1
  fi
  echo "$tag"
}

install_archive() {
  format="$1"
  url="$2"
  bin="$3" # Path to the extracted executable relative to TMPDIR

  archive="${2##*/}"
  name="${4:-${bin##*/}}"
  dir="${5:-${TMPDIR:-/tmp}}"
  out="$dir/$archive"

  bindir="$HOME/.local/bin"
  if [ ! -d "$bindir" ]; then
    echo >&2 "Creating directory: $bindir"
    mkdir -p "$bindir"
  fi

  echo >&2 "Downloading: $url"
  curl -LSfs "$url" -o "$out"
  echo >&2 "Extracting: $out"
  # shellcheck disable=SC2059
  eval "$(printf "$format" "$out" "$dir")"
  echo >&2 "Executable: $dir/$bin"
  chmod +x "$dir/$bin"
  echo >&2 "Moving to: $bindir/$name"
  mv "$dir/$bin" "$bindir/$name"
}

install_tar_gz() {
  install_archive 'tar -xzf "%s" -C "%s"' "$@"
}

install_zip() {
  install_archive 'unzip -o "%s" -d "%s"' "$@"
}

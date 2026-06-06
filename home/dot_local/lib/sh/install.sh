# shellcheck shell=sh

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
    die "invalid tag for URL: $url"
  elif [ "$version" = "Not Found" ]; then
    die "invalid URL: $url"
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
  *) die "unknown archive type: $extract_type" ;;
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

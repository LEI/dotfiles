# shellcheck shell=sh

# Check HTTP endpoint returns expected status code
# Usage: http_check <url> [expected_status]
http_check() {
  url="$1"
  expected="${2:-200}"
  auth="${3:-}"
  code=$(curl --silent --show-error --max-time 5 -o /dev/null -w "%{http_code}" \
    ${auth:+--user "$auth"} "$url")
  if [ "$code" = "$expected" ]; then
    msg "http_check $url: ok ($code)"
    return 0
  fi
  warn "http_check $url: expected $expected, got ${code:-no response}"
  return 1
}

# Retry a command with delay between attempts
# Usage: retry <attempts> <delay> <command...>
retry() {
  attempts="$1"
  delay="$2"
  shift 2
  i=0
  while [ "$i" -lt "$attempts" ]; do
    "$@" && return 0
    i=$((i + 1))
    [ "$i" -lt "$attempts" ] && sleep "$delay"
  done
  return 1
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

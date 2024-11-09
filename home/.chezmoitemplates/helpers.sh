#!/bin/sh

get_release() {
  repo="$1"
  alias="latest"
  url="https://github.com/$repo/releases/$alias"
  # shellcheck disable=SC1083
  tag="$(curl -s -w %{redirect_url} "$url")"
  echo "${tag##*/}"
}

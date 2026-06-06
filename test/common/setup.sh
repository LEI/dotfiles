#!/usr/bin/env bash

_common_setup() {
  bats_load_library bats-support
  bats_load_library bats-assert
  bats_load_library bats-file
  bats_load_library bats-mock/stub.bash

  # Per-test stub isolation: use BATS_MOCK_TMPDIR (unique per test)
  # instead of BATS_TMPDIR (shared per file) so stubs are parallel-safe
  BATS_MOCK_TMPDIR="$BATS_TEST_TMPDIR"
  BATS_MOCK_BINDIR="$BATS_MOCK_TMPDIR/bin"
  PATH="$BATS_MOCK_BINDIR:$PATH"

  # Prevent non-interactive bash subprocesses from sourcing .bashrc,
  # which rebuilds PATH and shadows bats-mock stubs
  unset BASH_ENV

  if [ -n "${PREFIX-}" ] && [ -f "$PREFIX/etc/tls/cert.pem" ]; then
    export SSL_CERT_FILE="$PREFIX/etc/tls/cert.pem"
  fi
}

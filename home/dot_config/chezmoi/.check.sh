#!/bin/sh

set -eu

if [ -n "${PREFIX:-}" ] && [ -z "${SHELL:-}" ]; then
  # WARN: SHELL must be defined
  # panic: runtime error: invalid memory address or nil pointer dereference
  # [signal SIGSEGV: segmentation violation code=0x1 addr=0x28 pc=0x55619f2fe5bd]
  # goroutine 1 [running]:
  # github.com/twpayne/go-shell.cgoGetUserShell({0x55619e70b5c0, 0x7})
  # /home/builder/.termux-build/_cache/go-path/pkg/mod/github.com/twpayne/go-shell@v0.5.0/shellcgo.go:41 +0x19d
  export SHELL="$PREFIX/bin/bash"
fi

exit_code=0
output="$(chezmoi doctor --dry-run --no-network)" || exit_code=$?

echo "$output" | grep -v '^\(info\|ok\)' || true

if [ "$exit_code" -ne 0 ]; then
  # echo "ERROR: chezmoi doctor exited with code $exit_code" >&2
  # exit "$exit_code"
  echo "WARN: chezmoi doctor exited with code $exit_code" >&2
fi

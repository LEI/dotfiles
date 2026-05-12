# shellcheck disable=SC2016,SC2154,SC2329

setup_file() {
  # shellcheck source=test/common/setup-file.sh
  source test/common/setup-file.sh
  _common_setup_file
}

setup() {
  # shellcheck source=test/common/setup.sh
  source test/common/setup.sh
  _common_setup
  # shellcheck source=test/common/helper.sh
  source test/common/helper.sh
}

source_vm() {
  export VM_PROVIDER="${TEST_VM_PROVIDER:-tart}"
  printf '#!/usr/bin/env bash\n' >"$BATS_TEST_TMPDIR/$VM_PROVIDER"
  chmod +x "$BATS_TEST_TMPDIR/$VM_PROVIDER"
  PATH="$BATS_TEST_TMPDIR:$PATH"
  # shellcheck source=script/vm
  source ./script/vm
  dirs=""
  image=test-image
  name=test-vm
  guest_os=linux
  gui=false
  keep=false
  tmux=false
  verbosity=1
}

# bats file_tags=script,vm

# bats test_tags=type:unit
@test "mount: skips when dirs is empty" {
  source_vm
  run --separate-stderr vm_mount
  assert_success
  refute_output
}

# bats test_tags=type:unit
@test "mount: darwin guest invokes mount_virtiofs per tag" {
  source_vm
  dirs="foo:/bar"
  guest_os=darwin
  vm_exec_sh() { echo "$@" >>"$BATS_TEST_TMPDIR/calls"; }
  run --separate-stderr vm_mount
  assert_success
  assert_stderr_line --partial "mounting foo at /Volumes/My Shared Files/foo"
  run cat "$BATS_TEST_TMPDIR/calls"
  assert_line --partial "mount_virtiofs"
  assert_line --partial "foo /Volumes/My Shared Files/foo"
}

# bats test_tags=type:unit
@test "mount: darwin guest mounts each tag in dirs" {
  source_vm
  dirs="foo:/bar baz:/qux"
  guest_os=darwin
  vm_exec_sh() { echo "${@: -2:1}" >>"$BATS_TEST_TMPDIR/tags"; }
  run --separate-stderr vm_mount
  assert_success
  run cat "$BATS_TEST_TMPDIR/tags"
  assert_line --index 0 foo
  assert_line --index 1 baz
}

# bats test_tags=type:unit
@test "mount: darwin guest bare path uses basename as tag" {
  source_vm
  dirs="/host/myname"
  guest_os=darwin
  vm_exec_sh() { echo "${@: -2:1}" >>"$BATS_TEST_TMPDIR/tags"; }
  run --separate-stderr vm_mount
  assert_success
  run cat "$BATS_TEST_TMPDIR/tags"
  assert_line --index 0 myname
}

# bats test_tags=type:unit
@test "mount: name:path entry uses prefix as tag" {
  source_vm
  dirs="myname:/host/path"
  # shellcheck disable=SC2329
  tart() { echo "$@"; }
  run --separate-stderr vm_mount
  assert_success
  # The actual stderr is just "mounting myname" (from log)
  # The mount command goes to stdout via the tart() mock
  assert_stderr_line --partial "mounting myname"
}

# bats test_tags=type:unit
@test "mount: bare path uses basename as tag" {
  source_vm
  # shellcheck disable=SC2030
  dirs="/host/path/chezmoi"
  # shellcheck disable=SC2329
  tart() { echo "$@"; }
  run --separate-stderr vm_mount
  assert_success
  # The actual stderr is just "mounting chezmoi" (from log)
  # The mount command goes to stdout via the tart() mock
  assert_stderr_line --partial "mounting chezmoi"
}

# bats test_tags=type:unit
@test "parse_flags: long flags set named globals" {
  source_vm
  parse_flags --gui --keep --tmux --quiet --name foo --dir a:/b -- ls -la
  assert_equal "$gui" true
  assert_equal "$keep" true
  assert_equal "$tmux" true
  assert_equal "$verbosity" 0
  assert_equal "$name" foo
  # shellcheck disable=SC2031
  assert_equal "$dirs" "a:/b"
  assert_equal "${ARGS[*]}" "ls -la"
}

# bats test_tags=type:unit
@test "parse_flags: collapsed short flags" {
  source_vm
  parse_flags -kv echo hi
  assert_equal "$keep" true
  assert_equal "$verbosity" 2
  assert_equal "${ARGS[*]}" "echo hi"
}

# bats test_tags=type:unit
@test "parse_flags: -- separator stops flag parsing" {
  source_vm
  parse_flags -- --dir a:/b
  assert_equal "${ARGS[*]}" "--dir a:/b"
}

# bats test_tags=type:unit
@test "parse_flags: unknown long flag exits" {
  source_vm
  run --separate-stderr parse_flags --unknown-flag
  assert_failure 2
  assert_stderr_line --partial "unknown option"
}

# bats test_tags=type:unit
@test "parse_flags: positional arg breaks loop" {
  source_vm
  parse_flags foo bar baz
  assert_equal "${ARGS[*]}" "foo bar baz"
}

# bats test_tags=type:unit
@test "restore_tty: skips stty when not a real tty" {
  source_vm
  real_tty() { return 1; }
  stty() { echo "stty called: $*" >>"$BATS_TEST_TMPDIR/stty"; }
  tty_state="dummy"
  restore_tty
  [ ! -e "$BATS_TEST_TMPDIR/stty" ]
}

# bats test_tags=type:unit
@test "restore_tty: noop when tty_state empty" {
  source_vm
  real_tty() { return 0; }
  stty() { echo "stty called" >>"$BATS_TEST_TMPDIR/stty"; }
  tty_state=""
  restore_tty
  [ ! -e "$BATS_TEST_TMPDIR/stty" ]
}

# bats test_tags=type:unit

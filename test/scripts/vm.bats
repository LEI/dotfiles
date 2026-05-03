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
@test "vm_mount: skips when dirs is empty" {
  source_vm
  run vm_mount
  assert_success
  refute_output
}

# bats test_tags=type:unit
@test "vm_mount: warns on non-tart provider" {
  TEST_VM_PROVIDER=vetu source_vm
  dirs="foo:/bar"
  run vm_mount
  assert_success
  assert_line --partial "does not support host directory sharing"
}

# bats test_tags=type:unit
@test "vm_mount: skips virtiofs on darwin guest" {
  source_vm
  dirs="foo:/bar"
  guest_os=darwin
  run vm_mount
  assert_success
  assert_line --partial "auto-mounted on macOS guests"
}

# bats test_tags=type:unit
@test "vm_mount: name:path entry uses prefix as tag" {
  source_vm
  dirs="myname:/host/path"
  # shellcheck disable=SC2329
  tart() { echo "$@"; }
  run vm_mount
  assert_success
  assert_line --partial "mount -t virtiofs myname"
}

# bats test_tags=type:unit
@test "vm_mount: bare path uses basename as tag" {
  source_vm
  # shellcheck disable=SC2030
  dirs="/host/path/chezmoi"
  # shellcheck disable=SC2329
  tart() { echo "$@"; }
  run vm_mount
  assert_success
  assert_line --partial "mount -t virtiofs chezmoi"
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
  assert_equal "${OUR_ARGS[*]}" "ls -la"
}

# bats test_tags=type:unit
@test "parse_flags: collapsed short flags" {
  source_vm
  parse_flags -kv echo hi
  assert_equal "$keep" true
  assert_equal "$verbosity" 2
  assert_equal "${OUR_ARGS[*]}" "echo hi"
}

# bats test_tags=type:unit
@test "parse_flags: -- separator stops flag parsing" {
  source_vm
  parse_flags -- --gui not-a-flag
  assert_equal "$gui" false
  assert_equal "${OUR_ARGS[*]}" "--gui not-a-flag"
}

# bats test_tags=type:unit
@test "parse_flags: unknown long flag exits" {
  source_vm
  run parse_flags --bogus
  assert_failure 2
  assert_line --partial "unknown option: --bogus"
}

# bats test_tags=type:unit
@test "parse_flags: positional arg breaks loop" {
  source_vm
  parse_flags echo hi -k
  assert_equal "$keep" false
  assert_equal "${OUR_ARGS[*]}" "echo hi -k"
}

# bats test_tags=type:unit
@test "main: no args prints help" {
  run ./script/vm
  assert_success
  assert_output --partial "Usage:"
}

# bats test_tags=type:unit
@test "main: unknown subcommand passes through to provider" {
  cat >"$BATS_TEST_TMPDIR/tart" <<'EOF'
#!/usr/bin/env bash
echo "tart-stub: $*"
EOF
  chmod +x "$BATS_TEST_TMPDIR/tart"
  VM_PROVIDER=tart PATH="$BATS_TEST_TMPDIR:$PATH" \
    run ./script/vm some-subcmd --flag value
  assert_success
  assert_line "tart-stub: some-subcmd --flag value"
}

# bats test_tags=type:unit
@test "main: alias triggers cmd_run" {
  source_vm
  vm_state() { echo running; }
  vm_exec_cmd() { echo "exec_cmd: $*"; }
  run main ubuntu echo hi
  assert_success
  assert_line "exec_cmd: echo hi"
}

# bats test_tags=type:unit
@test "cmd_run: URL target derives name from basename" {
  source_vm
  vm_state() { echo running; }
  vm_clone() { :; }
  vm_start() { :; }
  vm_wait() { :; }
  vm_mount() { :; }
  vm_stop() { :; }
  vm_exec_cmd() { echo "name=$name"; }
  keep=true
  name=""
  run cmd_run ghcr.io/foo/bar:latest true
  assert_success
  assert_line "name=bar"
}

# bats test_tags=type:unit
@test "cmd_run: unknown alias errors" {
  source_vm
  run cmd_run zzznotanalias
  assert_failure
  assert_line --partial "unknown alias: zzznotanalias"
}

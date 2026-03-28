setup() {
  source test/common/setup.sh
  _common_setup

  source test/common/helper.sh

  srv="$PWD/home/dot_local/bin/executable_srv"

  export XDG_CONFIG_HOME="$BATS_TEST_TMPDIR"
  mkdir -p "$BATS_TEST_TMPDIR/srv"
  cat >"$BATS_TEST_TMPDIR/srv/hosts.yaml" <<'YAML'
hosts:
  a:
    ssh: u@a
    dir: /d
    logs:
      cmd: tail -f log
  b:
    ssh: u@b
    dir: /d
YAML
}

# bats file_tags=srv,type:unit

@test "srv: no args lists hosts" {
  run --separate-stderr bash "$srv"
  assert_success
  assert_line "a"
  assert_line "b"
}

@test "srv: list subcommand" {
  run --separate-stderr bash "$srv" list
  assert_success
  assert_line "a"
}

@test "srv: connect defaults to shell" {
  stub ssh 'echo "$*"'
  run --separate-stderr bash "$srv" connect a
  unstub ssh
  assert_success
  assert_output --partial "exec \$SHELL -l"
}

@test "srv: connect with command" {
  stub ssh 'echo "$*"'
  run --separate-stderr bash "$srv" connect a echo ok
  unstub ssh
  assert_success
  assert_output --partial "echo ok"
}

@test "srv: shorthand connect" {
  stub ssh 'echo "$*"'
  run --separate-stderr bash "$srv" a echo ok
  unstub ssh
  assert_success
  assert_output --partial "echo ok"
}

@test "srv: flags pass through to remote" {
  stub ssh 'echo "$*"'
  run --separate-stderr bash "$srv" a ls -h
  unstub ssh
  assert_success
  assert_output --partial "ls -h"
}

@test "srv: unknown host fails" {
  run --separate-stderr bash "$srv" nope
  assert_failure
  assert_stderr --partial "unknown host"
}

@test "srv: logs tails on host" {
  stub ssh 'echo "$*"'
  run --separate-stderr bash "$srv" logs a
  unstub ssh
  assert_success
  assert_output --partial "tail -f log"
}

@test "srv: logs passes extra args" {
  stub ssh 'echo "$*"'
  run --separate-stderr bash "$srv" logs a -n 50
  unstub ssh
  assert_success
  assert_output --partial "tail -f log -n 50"
}

@test "srv: logs without name fails" {
  run --separate-stderr bash "$srv" logs
  assert_failure
}

@test "srv: help shows usage" {
  run --separate-stderr bash "$srv" help
  assert_success
  assert_output --partial "Usage: srv"
}

@test "srv: help subcommand shows subcommand usage" {
  run --separate-stderr bash "$srv" help logs
  assert_success
  assert_output --partial "Usage: srv logs"
}

@test "srv: missing config fails" {
  export XDG_CONFIG_HOME="$BATS_TEST_TMPDIR/empty"
  run --separate-stderr bash "$srv"
  assert_failure
  assert_stderr --partial "config not found"
}

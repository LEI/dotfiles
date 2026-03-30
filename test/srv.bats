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
  run_script "$srv"
  assert_success
  assert_line "a"
  assert_line "b"
}

@test "srv: list subcommand" {
  run_script "$srv" list
  assert_success
  assert_line "a"
}

@test "srv: connect defaults to shell" {
  stub ssh 'echo "$*"'
  run_script "$srv" connect a
  unstub ssh
  assert_success
  assert_line --regexp 'exec \$SHELL -l$'
}

@test "srv: connect with command" {
  stub ssh 'echo "$*"'
  run_script "$srv" connect a echo ok
  unstub ssh
  assert_success
  assert_line --regexp "echo ok$"
}

@test "srv: shorthand connect" {
  stub ssh 'echo "$*"'
  run_script "$srv" a echo ok
  unstub ssh
  assert_success
  assert_line --regexp "echo ok"
}

@test "srv: flags pass through to remote" {
  stub ssh 'echo "$*"'
  run_script "$srv" a ls -h
  unstub ssh
  assert_success
  assert_line --regexp "ls -h$"
}

@test "srv: unknown host fails" {
  run_script "$srv" nope
  assert_failure
  assert_stderr_line --regexp "^srv: unknown host"
}

@test "srv: logs tails on host" {
  stub ssh 'echo "$*"'
  run_script "$srv" logs a
  unstub ssh
  assert_success
  assert_line --regexp "tail -f log$"
}

@test "srv: logs passes extra args" {
  stub ssh 'echo "$*"'
  run_script "$srv" logs a -n 50
  unstub ssh
  assert_success
  assert_line --regexp "tail -f log -n 50$"
}

@test "srv: logs without name fails" {
  run_script "$srv" logs
  assert_failure
}

@test "srv: help shows usage" {
  run_script "$srv" help
  assert_success
  assert_line --regexp "^Usage: srv"
}

@test "srv: help subcommand shows subcommand usage" {
  run_script "$srv" help logs
  assert_success
  assert_line --regexp "^Usage: srv logs"
}

@test "srv: missing config fails" {
  export XDG_CONFIG_HOME="$BATS_TEST_TMPDIR/empty"
  run_script "$srv"
  assert_failure
  assert_stderr_line --regexp "^srv: config not found"
}

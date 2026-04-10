setup() {
  source test/common/setup.sh
  _common_setup

  source test/common/helper.sh

  srv="$PWD/home/dot_local/bin/executable_srv"

  export XDG_CONFIG_HOME="$BATS_TEST_TMPDIR"
  mkdir -p "$BATS_TEST_TMPDIR/srv"
  cat >"$BATS_TEST_TMPDIR/srv/hosts.yaml" <<'YAML'
hosts:
  web:
    ssh: u@web
    dir: /var/www
    logs:
      cmd: tail --follow log
      pipe: cat -n
  api:
    ssh: u@api
    dir: /srv
YAML
}

# bats file_tags=srv,type:unit

# Listing

@test "srv: no args lists hosts" {
  run_script "$srv"
  assert_success
  assert_line "web"
  assert_line "api"
}

# Help

@test "srv: -h shows usage" {
  run_script "$srv" -h
  assert_success
  assert_line --regexp "^Usage: srv"
}

@test "srv: --help shows usage" {
  run_script "$srv" --help
  assert_success
  assert_line --regexp "^Usage: srv"
}

# Connect

@test "srv: host opens interactive shell" {
  stub ssh 'echo "$*"'
  run_script "$srv" web
  unstub ssh
  assert_success
  assert_line --regexp 'exec \$SHELL -l$'
}

@test "srv: host with command runs it" {
  stub ssh 'echo "$*"'
  run_script "$srv" web echo ok
  unstub ssh
  assert_success
  assert_line --regexp "echo ok$"
}

@test "srv: flags pass through to remote" {
  stub ssh 'echo "$*"'
  run_script "$srv" web ls -h
  unstub ssh
  assert_success
  assert_line --regexp "ls -h$"
}

@test "srv: unknown host fails" {
  run_script "$srv" nope
  assert_failure
  assert_stderr_line --regexp "^srv: unknown host"
}

# Logs

@test "srv: host logs streams log command" {
  stub ssh 'echo "$*"'
  run_script "$srv" web logs
  unstub ssh
  assert_success
  assert_line --regexp "tail --follow log$"
}

@test "srv: host logs passes extra args" {
  stub ssh 'echo "$*"'
  run_script "$srv" web logs --lines=50
  unstub ssh
  assert_success
  assert_line --regexp "tail --follow log --lines=50$"
}

@test "srv: logs without config fails" {
  stub ssh 'echo "$*"'
  run_script "$srv" api logs
  unstub ssh || true
  assert_failure
  assert_stderr_line --regexp "^srv: no log command"
}

# Debug

@test "srv: -d prints ssh command without executing" {
  run_script "$srv" -d web
  assert_success
  assert_line --regexp '^ssh -t u@web "cd '
}

@test "srv: -d logs shows command without -t" {
  run_script "$srv" -d web logs
  assert_success
  assert_line --regexp '^ssh u@web "cd '
  refute_output --regexp ' -t '
}

@test "srv: -d logs with args omits pipe" {
  run_script "$srv" -d web logs --lines=50
  assert_success
  refute_output --regexp "cat -n"
}

# Config

@test "srv: missing config fails" {
  export XDG_CONFIG_HOME="$BATS_TEST_TMPDIR/empty"
  run_script "$srv"
  assert_failure
  assert_stderr_line --regexp "^srv: config not found"
}

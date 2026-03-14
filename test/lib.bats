setup() {
  source test/common/setup.sh
  _common_setup
}

# bats file_tags=lib,type:unit

# export_env

@test "export_env: sources conf and exports variables" {
  local conf="$BATS_TEST_TMPDIR/test.conf"
  printf 'FOO=bar\nBAZ=qux\n' >"$conf"
  source home/dot_config/sh/lib/export.sh
  export_env "$conf"
  [ "$FOO" = bar ]
  [ "$BAZ" = qux ]
}

@test "export_env: missing file is silently skipped" {
  source home/dot_config/sh/lib/export.sh
  run export_env "$BATS_TEST_TMPDIR/nonexistent.conf"
  assert_success
}

@test "export_env: fails with no arguments" {
  source home/dot_config/sh/lib/export.sh
  run export_env
  assert_failure
}

setup() {
  source test/common/setup.sh
  _common_setup

  source test/common/helper.sh
}

# bats file_tags=env,type:smoke

path_duplicates() {
  echo "$PATH" | tr ":" "\n" | sort | uniq --count | grep -v "^\s\+1 "
}

@test "path: unique entries" {
  [ "${CI:-}" != true ] || skip "CI may have PATH duplicates"
  run --separate-stderr path_duplicates
  refute_output
  refute_stderr
  assert_failure
}

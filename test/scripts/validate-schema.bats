# shellcheck disable=SC2154,SC2016

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

  check_command check-jsonschema jq
}

# bats file_tags=script,validate-schema

# bats test_tags=type:unit
@test "validate-schema: passes file with valid schema" {
  local schema="$BATS_TEST_TMPDIR/schema.json"
  local file="$BATS_TEST_TMPDIR/valid.json"

  printf '{"type":"object","properties":{"name":{"type":"string"}}}' >"$schema"
  printf '{"$schema":"%s","name":"ok"}' "$schema" >"$file"

  run_script ./script/validate-schema --verbose "$file"
  assert_line "PASS $file schema=$schema"
  assert_success
}

# bats test_tags=type:unit
@test "validate-schema: fails invalid file and surfaces error" {
  local schema="$BATS_TEST_TMPDIR/schema.json"
  local file="$BATS_TEST_TMPDIR/invalid.json"

  printf '{"type":"object","required":["name"],"properties":{"name":{"type":"string"}}}' >"$schema"
  printf '{"$schema":"%s","other":"value"}' "$schema" >"$file"

  run_script ./script/validate-schema "$file"
  assert_line "FAIL $file schema=$schema"
  assert_stderr_line "validate-schema: 0 passed, 1 failed, 0 skipped"
  assert_failure
}

# bats test_tags=type:unit
@test "validate-schema: skips file without schema" {
  local file="$BATS_TEST_TMPDIR/no-schema.json"

  printf '{"name":"test"}' >"$file"

  run_script ./script/validate-schema --verbose "$file"
  assert_line "SKIP $file (no \$schema)"
  assert_stderr_line "validate-schema: 0 passed, 0 failed, 1 skipped"
  assert_success
}

# bats test_tags=type:unit
@test "validate-schema: summary counts mixed results correctly" {
  local schema="$BATS_TEST_TMPDIR/schema.json"
  local valid="$BATS_TEST_TMPDIR/valid.json"
  local invalid="$BATS_TEST_TMPDIR/invalid.json"

  printf '{"type":"object","required":["name"],"properties":{"name":{"type":"string"}}}' >"$schema"
  printf '{"$schema":"%s","name":"ok"}' "$schema" >"$valid"
  printf '{"$schema":"%s","other":"value"}' "$schema" >"$invalid"

  run_script ./script/validate-schema "$valid" "$invalid"
  assert_stderr_line "validate-schema: 1 passed, 1 failed, 0 skipped"
  assert_failure
}

# bats test_tags=type:unit
@test "validate-schema: handles yaml files" {
  local schema="$BATS_TEST_TMPDIR/schema.json"
  local file="$BATS_TEST_TMPDIR/test.yaml"

  printf '{"type":"object","properties":{"name":{"type":"string"}}}' >"$schema"
  printf '$schema: "%s"\nname: ok' "$schema" >"$file"

  run_script ./script/validate-schema "$file"
  assert_stderr_line "validate-schema: 1 passed, 0 failed, 0 skipped"
  assert_success
}

# bats test_tags=type:unit
@test "validate-schema: handles toml files" {
  local schema="$BATS_TEST_TMPDIR/schema.json"
  local file="$BATS_TEST_TMPDIR/test.toml"

  printf '{"type":"object","properties":{"name":{"type":"string"}}}' >"$schema"
  printf '"$schema" = "%s"\nname = "ok"' "$schema" >"$file"

  run_script ./script/validate-schema --verbose "$file"
  assert_line "PASS $file schema=$schema"
  assert_stderr_line "validate-schema: 1 passed, 0 failed, 0 skipped"
  assert_success
}

# bats test_tags=type:unit
@test "validate-schema: handles json5 files" {
  check_command json5
  local schema="$BATS_TEST_TMPDIR/schema.json"
  local file="$BATS_TEST_TMPDIR/test.json5"

  printf '{"type":"object","properties":{"name":{"type":"string"}}}' >"$schema"
  printf '{\n  $schema: "%s",\n  name: "ok",\n  // comment\n}' "$schema" >"$file"

  run_script ./script/validate-schema "$file"
  assert_stderr_line "validate-schema: 1 passed, 0 failed, 0 skipped"
  assert_success
}

# bats test_tags=type:unit
@test "validate-schema: handles jsonc files" {
  check_command json5
  local schema="$BATS_TEST_TMPDIR/schema.json"
  local file="$BATS_TEST_TMPDIR/test.jsonc"

  printf '{"type":"object","properties":{"name":{"type":"string"}}}' >"$schema"
  printf '{\n  $schema: "%s",\n  name: "ok",\n  /* comment */\n}' "$schema" >"$file"

  run_script ./script/validate-schema "$file"
  assert_stderr_line "validate-schema: 1 passed, 0 failed, 0 skipped"
  assert_success
}

# bats test_tags=type:unit
@test "validate-schema: handles cspell.json as jsonc" {
  local schema="$BATS_TEST_TMPDIR/schema.json"
  local file="$BATS_TEST_TMPDIR/cspell.json"

  printf '{"type":"object","properties":{"version":{"type":"string"}}}' >"$schema"
  printf '{"$schema":"%s","version":"0.2"}' "$schema" >"$file"

  run_script ./script/validate-schema "$file"
  assert_stderr_line "validate-schema: 1 passed, 0 failed, 0 skipped"
  assert_success
}

# bats test_tags=type:unit
@test "validate-schema: handles schema with null value" {
  local file="$BATS_TEST_TMPDIR/null-schema.json"

  printf '{"$schema":null,"name":"ok"}' >"$file"

  run_script ./script/validate-schema --verbose "$file"
  assert_stderr_line "validate-schema: 0 passed, 0 failed, 1 skipped"
  assert_success
}

# bats test_tags=type:unit
@test "validate-schema: --help shows usage" {
  run_script ./script/validate-schema --help
  assert_line --regexp "^Usage:"
  assert_success
}

# bats test_tags=type:unit
@test "validate-schema: --usage shows usage specs" {
  run_script ./script/validate-schema --usage
  assert_line --partial "--keep"
  assert_line --partial "--quiet"
  assert_line --partial "--verbose"
  assert_success
}

# bats test_tags=type:unit
@test "validate-schema: --separator handles argument separator" {
  local schema="$BATS_TEST_TMPDIR/schema.json"
  local file="$BATS_TEST_TMPDIR/valid.json"

  printf '{"type":"object","properties":{"name":{"type":"string"}}}' >"$schema"
  printf '{"$schema":"%s","name":"ok"}' "$schema" >"$file"

  run_script ./script/validate-schema -- "$file"
  assert_stderr_line "validate-schema: 1 passed, 0 failed, 0 skipped"
  assert_success
}

# bats test_tags=type:unit
@test "validate-schema: handles no files case" {
  local empty_dir script
  empty_dir=$(mktemp -d)
  script="$BATS_TEST_DIRNAME/../../script/validate-schema"
  cd "$empty_dir"
  git init --quiet
  run_script "$script"
  assert_stderr_line --regexp "^validate-schema: no files to validate$"
  assert_success
}

# bats test_tags=type:unit
@test "validate-schema: fails on file not found" {
  run_script ./script/validate-schema "/nonexistent/file.json"
  assert_line "FAIL /nonexistent/file.json schema= (file not found)"
  assert_failure
}

# bats test_tags=type:unit
@test "validate-schema: --keep shows file and schema paths on failure" {
  check_command json5
  local schema="$BATS_TEST_TMPDIR/schema.json"
  local file="$BATS_TEST_TMPDIR/test.jsonc"

  printf '{"type":"object","required":["name"],"properties":{"name":{"type":"string"}}}' >"$schema"
  printf '{\n  $schema: "%s",\n  /* comment */\n}' "$schema" >"$file"

  run_script ./script/validate-schema --keep "$file"
  assert_stderr_line --partial "file: "
  assert_stderr_line --partial "schema: "
  assert_failure
}

# bats test_tags=type:unit
@test "validate-schema: --verbose shows validation details" {
  local schema="$BATS_TEST_TMPDIR/schema.json"
  local file="$BATS_TEST_TMPDIR/valid.json"

  printf '{"type":"object","properties":{"name":{"type":"string"}}}' >"$schema"
  printf '{"$schema":"%s","name":"ok"}' "$schema" >"$file"

  run_script ./script/validate-schema --verbose "$file"
  assert_stderr_line --regexp "validate-schema: validating "
  assert_success
}

# bats test_tags=type:unit
@test "validate-schema: handles jsonc with null content" {
  check_command json5
  local schema="$BATS_TEST_TMPDIR/schema.json"
  local file="$BATS_TEST_TMPDIR/test.jsonc"

  printf '{"type":"object","properties":{"name":{"type":"string"}}}' >"$schema"
  printf 'null' >"$file"

  run_script ./script/validate-schema "$file"
  assert_success
}

setup_file() {
  source test/common/setup-file.sh
  _common_setup_file
  export BATS_NO_PARALLELIZE_WITHIN_FILE=true
}

setup() {
  source test/common/setup.sh
  _common_setup
  # Paths reused per test; BATS_TEST_TMPDIR is unique per test
  BIF_WRAPPER="$BATS_TEST_TMPDIR/bif-wrapper.tmpl"
  BIF_CONTENTS="$BATS_TEST_TMPDIR/bif-contents.txt"
}

# Run an inline chezmoi template expression and capture output.
run_template() {
  run --separate-stderr chezmoi execute-template "$@"
}

# bats file_tags=template

# Run block-in-file with the given existing file content and block body.
# Contents are written to a temp file and read via `include` to avoid quoting.
# Optional extra_dict_args: additional "key" "value" pairs appended to the dict.
run_block_in_file() {
  local existing_file="$1"
  local block_body="$2"
  local extra_dict_args="${3:-}"

  printf "%s" "$block_body" >"$BIF_CONTENTS"

  printf '{{- includeTemplate "block-in-file.tmpl" (dict "chezmoi" .chezmoi "contents" (include "%s")%s) -}}' \
    "$BIF_CONTENTS" "$extra_dict_args" >"$BIF_WRAPPER"

  run --separate-stderr bash -c \
    'printf "%s" "$1" | chezmoi execute-template --with-stdin -f "$2"' \
    _ "$existing_file" "$BIF_WRAPPER"
}

@test "block-in-file: fresh file — block appended after existing content" {
  run_block_in_file $'before content\n' "new"
  assert_success
  assert_line "before content"
  assert_line --partial "### START"
  assert_line "new"
  assert_line --partial "### END"
}

@test "block-in-file: empty file — block written" {
  run_block_in_file "" "body"
  assert_success
  assert_line --partial "### START"
  assert_line "body"
  assert_line --partial "### END"
}

@test "block-in-file: block contents replaced on update" {
  run_block_in_file $'### START x\nold\n### END x\n' "new"
  assert_success
  refute_line "old"
  assert_line "new"
}

@test "block-in-file: content before block preserved" {
  run_block_in_file $'header\n### START x\nold\n### END x\n' "new"
  assert_success
  assert_line "header"
}

@test "block-in-file: blank line after END preserved" {
  run_block_in_file $'### START x\nold\n### END x\n\nafter\n' "new"
  assert_success
  # Blank line must appear between END marker and after
  [[ "$output" == *$'### END'*$'\n\nafter' ]]
}

@test "block-in-file: content after block without blank line preserved" {
  run_block_in_file $'### START x\nold\n### END x\nafter\n' "new"
  assert_success
  assert_line "after"
}

@test "block-in-file: content before and after block both preserved" {
  run_block_in_file $'header\n### START x\nold\n### END x\n\nfooter\n' "new"
  assert_success
  assert_line "header"
  assert_line "footer"
}

@test "block-in-file: idempotent — applying twice yields same output" {
  run_block_in_file $'before\n' "content"
  local first_output="$output"
  run_block_in_file "$first_output" "content"
  assert_success
  assert_output "$first_output"
}

@test "block-in-file: contents with special chars preserved verbatim" {
  run_block_in_file "" 'echo "$HOME" # comment'
  assert_success
  assert_line 'echo "$HOME" # comment'
}

@test "block-in-file: custom commentString changes marker prefix" {
  run_block_in_file "" "val" ' "commentString" "//"'
  assert_success
  assert_line --partial "/// START"
  assert_line --partial "/// END"
  refute_line --partial "### START"
}

@test "block-in-file: empty block body writes empty block" {
  run_block_in_file "" ""
  assert_success
  assert_line --partial "### START"
  assert_line --partial "### END"
}

@test "block-in-file: multiple blank lines after END all preserved" {
  run_block_in_file $'### START x\nold\n### END x\n\n\nafter\n' "new"
  assert_success
  [[ "$output" == *$'### END'*$'\n\n\nafter' ]]
}

# pluck

@test "pluck: extracts named field from list of dicts" {
  run_template '{{- includeTemplate "pluck.tmpl" (dict "key" "name" "values" (list (dict "name" "beta") (dict "name" "alpha"))) -}}'
  assert_success
  assert_line "alpha"
  assert_line "beta"
}

@test "pluck: deduplicates values" {
  run_template '{{- includeTemplate "pluck.tmpl" (dict "key" "name" "values" (list (dict "name" "a") (dict "name" "a") (dict "name" "b"))) -}}'
  assert_success
  local count
  count="$(grep -c "^a$" <<<"$output")"
  [ "$count" -eq 1 ]
}

@test "pluck: sorts output alphabetically" {
  run_template '{{- includeTemplate "pluck.tmpl" (dict "key" "name" "values" (list (dict "name" "zebra") (dict "name" "apple") (dict "name" "mango"))) -}}'
  assert_success
  # pluck emits a blank line before each value; filter them out
  local sorted=()
  mapfile -t sorted < <(printf "%s\n" "$output" | grep -v '^$')
  [[ "${sorted[0]}" == "apple" ]]
  [[ "${sorted[1]}" == "mango" ]]
  [[ "${sorted[2]}" == "zebra" ]]
}

@test "pluck: missing field entries are skipped" {
  run_template '{{- includeTemplate "pluck.tmpl" (dict "key" "name" "values" (list (dict "name" "present") (dict "other" "ignored"))) -}}'
  assert_success
  assert_line "present"
  refute_line "ignored"
}

@test "pluck: empty values list produces no output" {
  run_template '{{- includeTemplate "pluck.tmpl" (dict "key" "name" "values" list) -}}'
  assert_success
  assert_output ""
}

# cpu-cores / cpu-threads


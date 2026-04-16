setup_file() {
  # shellcheck source=test/common/setup-file.sh
  source test/common/setup-file.sh
  _common_setup_file
}

setup() {
  # shellcheck source=test/common/setup.sh
  source test/common/setup.sh
  _common_setup
  # Paths reused per test; BATS_TEST_TMPDIR is unique per test
  BIF_WRAPPER="$BATS_TEST_TMPDIR/bif-wrapper.tmpl"
  BIF_CONTENTS="$BATS_TEST_TMPDIR/bif-contents.txt"
}

# Run an inline chezmoi template expression and capture output
run_template() {
  run --separate-stderr chezmoi execute-template "$@"
}

# bats file_tags=template,type:unit

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

  # shellcheck disable=SC2016
  run --separate-stderr bash -c \
    'printf "%s" "$1" | chezmoi execute-template --with-stdin -f "$2"' \
    _ "$existing_file" "$BIF_WRAPPER"
}

@test "block-in-file: appends block to fresh file" {
  run_block_in_file $'before content\n' "new"
  assert_success
  assert_line "before content"
  assert_line --regexp "^### START"
  assert_line "new"
  assert_line --regexp "^### END"
}

@test "block-in-file: writes block to empty file" {
  run_block_in_file "" "body"
  assert_success
  assert_line --regexp "^### START"
  assert_line "body"
  assert_line --regexp "^### END"
}

@test "block-in-file: replaces block contents on update" {
  run_block_in_file $'### START x\nold\n### END x\n' "new"
  assert_success
  refute_line "old"
  assert_line "new"
}

@test "block-in-file: preserves content before block" {
  run_block_in_file $'header\n### START x\nold\n### END x\n' "new"
  assert_success
  assert_line "header"
}

@test "block-in-file: preserves blank line after END" {
  run_block_in_file $'### START x\nold\n### END x\n\nafter\n' "new"
  assert_success
  # Blank line must appear between END marker and after
  [[ "$output" == *$'### END'*$'\n\nafter' ]]
}

@test "block-in-file: preserves content after block without blank line" {
  run_block_in_file $'### START x\nold\n### END x\nafter\n' "new"
  assert_success
  assert_line "after"
}

@test "block-in-file: preserves content before and after block" {
  run_block_in_file $'header\n### START x\nold\n### END x\n\nfooter\n' "new"
  assert_success
  assert_line "header"
  assert_line "footer"
}

@test "block-in-file: produces same output when applied twice" {
  run_block_in_file $'before\n' "content"
  local first_output="$output"
  run_block_in_file "$first_output" "content"
  assert_success
  assert_output "$first_output"
}

@test "block-in-file: preserves special chars verbatim" {
  # shellcheck disable=SC2016
  run_block_in_file "" 'echo "$HOME" # comment'
  assert_success
  # shellcheck disable=SC2016
  assert_line 'echo "$HOME" # comment'
}

@test "block-in-file: uses custom commentString as marker prefix" {
  run_block_in_file "" "val" ' "commentString" "/"'
  assert_success
  assert_line --regexp "^/// START"
  assert_line --regexp "^/// END"
  refute_line --regexp "^### START"
}

@test "block-in-file: writes markers for empty block body" {
  run_block_in_file "" ""
  assert_success
  assert_line --regexp "^### START"
  assert_line --regexp "^### END"
}

@test "block-in-file: collapses multiple blank lines after END" {
  run_block_in_file $'### START x\nold\n### END x\n\n\nafter\n' "new"
  assert_success
  [[ "$output" == *$'### END'*$'\n\nafter' ]]
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

@test "pluck: skips entries without matching field" {
  run_template '{{- includeTemplate "pluck.tmpl" (dict "key" "name" "values" (list (dict "name" "present") (dict "other" "ignored"))) -}}'
  assert_success
  assert_line "present"
  refute_line "ignored"
}

@test "pluck: produces no output for empty values" {
  run_template '{{- includeTemplate "pluck.tmpl" (dict "key" "name" "values" list) -}}'
  assert_success
  assert_output ""
}

# package-hooks

@test "package-hooks: emits header and body for before_script" {
  run_template '{{- includeTemplate "package-hooks.tmpl" (dict "key" "before_script" "values" (list (dict "before_script" "echo setup"))) -}}'
  assert_success
  assert_line "# Before script:"
  assert_line "echo setup"
}

@test "package-hooks: includes label in header" {
  run_template '{{- includeTemplate "package-hooks.tmpl" (dict "key" "after_script" "values" (list (dict "after_script" "echo done")) "label" "brew") -}}'
  assert_success
  assert_line "# After script (brew):"
}

@test "package-hooks: produces no output without matching values" {
  run_template '{{- includeTemplate "package-hooks.tmpl" (dict "key" "before_script" "values" list) -}}'
  assert_success
  assert_output ""
}

# cpu-cores / cpu-threads

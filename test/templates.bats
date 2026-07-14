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

  printf "%s" "$block_body" >|"$BIF_CONTENTS"

  printf '{{- includeTemplate "block-in-file.tmpl" (dict "chezmoi" .chezmoi "contents" (include "%s")%s) -}}' \
    "$BIF_CONTENTS" "$extra_dict_args" >|"$BIF_WRAPPER"

  # shellcheck disable=SC2016
  run --separate-stderr bash -c \
    'printf "%s" "$1" | chezmoi execute-template --with-stdin -f "$2"' \
    _ "$existing_file" "$BIF_WRAPPER"
}

@test "block-in-file: appends block after existing content" {
  run_block_in_file $'before content\n' "new"
  assert_success
  assert_line "before content"
  assert_line --regexp "^### START"
  assert_line "new"
  assert_line --regexp "^### END"
}

@test "block-in-file: handles empty file and empty body" {
  run_block_in_file "" ""
  assert_success
  assert_line --regexp "^### START"
  assert_line --regexp "^### END"
  refute_output --regexp $'\n\n\n'
}

@test "block-in-file: replaces in-place, preserves surrounding content" {
  run_block_in_file $'header\n### START x\nold\n### END x\n\nfooter\n' "new"
  assert_success
  assert_line "header"
  assert_line "new"
  assert_line "footer"
  refute_line "old"
  [[ "$output" == *$'header'*$'### START'*$'### END'*$'footer'* ]]
}

@test "block-in-file: collapses blank lines around block to single" {
  run_block_in_file $'### START x\nold\n### END x\n\n\nafter\n' "new"
  assert_success
  [[ "$output" == *$'### END'*$'\n\nafter'* ]]
  refute_output --regexp $'### END[^\n]*\n\n\n'
}

@test "block-in-file: idempotent on re-apply" {
  run_block_in_file $'before\n' "content"
  local first_output="$output"
  run_block_in_file "$first_output" "content"
  assert_success
  assert_output "$first_output"
}

@test "block-in-file: uses custom commentString as marker prefix" {
  run_block_in_file "" "val" ' "commentString" "/"'
  assert_success
  assert_line --regexp "^/// START"
  assert_line --regexp "^/// END"
}

@test "block-in-file: preserves special chars verbatim" {
  # shellcheck disable=SC2016
  run_block_in_file "" 'echo "$HOME" # ${var}'
  assert_success
  # shellcheck disable=SC2016
  assert_line 'echo "$HOME" # ${var}'
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

# filter-packages

@test "filter-packages: allowlist type appends version to name" {
  run_template '{{- includeTemplate "filter-packages.json.tmpl" (dict "packageType" "npm" "defaultType" "npm" "input" (dict "foo" (dict "version" "1.2.3"))) -}}'
  assert_success
  assert_output --partial '"foo@1.2.3"'
  refute_output --partial '"foo":'
  refute_stderr
}

@test "filter-packages: non-allowlist type keeps original name and warns" {
  run_template '{{- includeTemplate "filter-packages.json.tmpl" (dict "packageType" "cask" "defaultType" "cask" "input" (dict "foo" (dict "version" "1.2.3"))) -}}'
  assert_success
  assert_output --partial '"foo"'
  refute_output --partial '"foo@'
  assert_stderr_line --partial 'cask ignores version pin'
}

@test "filter-packages: version pin on excluded type does not warn" {
  run_template '{{- includeTemplate "filter-packages.json.tmpl" (dict "packageType" "cask" "defaultType" "cask" "input" (dict "foo" (dict "version" "1.2.3" "type" "mise"))) -}}'
  assert_success
  refute_output --partial '"foo"'
  refute_stderr
}

@test "filter-packages: version pin on disabled package does not warn" {
  run_template '{{- includeTemplate "filter-packages.json.tmpl" (dict "packageType" "cask" "defaultType" "cask" "input" (dict "foo" (dict "version" "1.2.3" "enabled" "false"))) -}}'
  assert_success
  refute_output --partial '"foo"'
  refute_stderr
}

@test "filter-packages: mise type retains version in dict without appending" {
  run_template '{{- includeTemplate "filter-packages.json.tmpl" (dict "packageType" "mise" "defaultType" "mise" "input" (dict "foo" (dict "version" "1.2.3"))) -}}'
  assert_success
  assert_output --partial '"foo"'
  assert_output --partial '"version":"1.2.3"'
  refute_output --partial '"foo@'
  refute_stderr
}

@test "filter-packages: empty version never appends trailing @" {
  run_template '{{- includeTemplate "filter-packages.json.tmpl" (dict "packageType" "npm" "defaultType" "npm" "input" (dict "foo" (dict "version" ""))) -}}'
  assert_success
  refute_output --partial '"foo@'
  assert_output --partial '"foo"'
  refute_stderr
}

# container-provider

@test "container-provider: falls back to the OS-aware default when no override is set" {
  mkdir -p "$BATS_TEST_TMPDIR/home"
  local expected
  [ "$UNAME" = Darwin ] && expected=docker || expected=podman
  HOME="$BATS_TEST_TMPDIR/home" \
    run_template '{{- includeTemplate "container-provider.tmpl" (dict "chezmoi" .chezmoi) -}}'
  assert_success
  assert_output "$expected"
}

@test "container-provider: empty inside a container, no engine is nested" {
  mkdir -p "$BATS_TEST_TMPDIR/home"
  HOME="$BATS_TEST_TMPDIR/home" \
    run_template '{{- includeTemplate "container-provider.tmpl" (dict "chezmoi" .chezmoi "container" true) -}}'
  assert_success
  assert_output ""
}

@test "container-provider: per-machine local.yaml override wins over the OS default" {
  mkdir -p "$BATS_TEST_TMPDIR/home"
  printf 'containerProvider: docker\n' >"$BATS_TEST_TMPDIR/home/local.yaml"
  HOME="$BATS_TEST_TMPDIR/home" \
    run_template '{{- includeTemplate "container-provider.tmpl" (dict "chezmoi" .chezmoi) -}}'
  assert_success
  assert_output "docker"
}

# mise-tools

@test "mise-tools: tool with version lts renders lts" {
  run_template '{{- includeTemplate "mise-tools.toml.tmpl" (dict "packages" (dict "mise" (dict "node" (dict "version" "lts")))) -}}'
  assert_success
  assert_output --partial 'node = "lts"'
}

@test "mise-tools: tool with embedded @version in name takes precedence" {
  run_template '{{- includeTemplate "mise-tools.toml.tmpl" (dict "packages" (dict "mise" (dict "npm:@foo/bar@1.2.3" (dict)))) -}}'
  assert_success
  assert_output --partial '"npm:@foo/bar" = {'
  assert_output --partial 'version = "1.2.3"'
}

@test "mise-tools: minimum_release_age renders as tool option" {
  run_template '{{- includeTemplate "mise-tools.toml.tmpl" (dict "packages" (dict "mise" (dict "cargo:foo" (dict "minimum_release_age" "0d")))) -}}'
  assert_success
  assert_output --partial '"cargo:foo" = {'
  assert_output --partial 'minimum_release_age = "0d"'
  assert_output --partial 'version = "latest"'
}

# process-compose data

@test "process-compose: .data.yaml exposes services and processCompose at root" {
  run_template '{{- includeTemplate "data.tmpl" (dict "dir" "dot_config/process-compose" "chezmoi" .chezmoi) -}}'
  assert_success
  assert_line --regexp '^processCompose:'
  assert_line --regexp '^services:'
  assert_line --partial 'label: com.process-compose'
}

# cpu-cores / cpu-threads

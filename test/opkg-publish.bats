# shellcheck disable=SC2154

setup_file() {
  # shellcheck source=test/common/setup-file.sh
  source test/common/setup-file.sh
  _common_setup_file
}

setup() {
  # shellcheck source=test/common/setup.sh
  source test/common/setup.sh
  _common_setup
}

# bats file_tags=opkg

# Render the install template and extract just the publish_package helper
# plus its opkg dependency, stopping before the executable publish/install
# body so sourcing never runs opkg against the real marketplace tree.
_publish_helpers() {
  chezmoi execute-template <home/dot_openpackage/.opkg-install.tmpl |
    sed -n '/^opkg()/,/^# Per-resource install/p'
}

# Build a hermetic fixture package with a sentinel resource file.
_make_fixture() {
  local root="$1"
  mkdir -p "$root/skills/foo"
  printf 'name: fixturepkg\nversion: 0.0.1\n' >"$root/openpackage.yml"
  echo "SENTINEL" >"$root/skills/foo/SKILL.md"
}

# publish_package must never make the live source the publish CWD:
# opkg publish can move a package's resources into the registry, which would
# empty the source. Publishing from a copy is the guard. This mock records the
# CWD opkg sees, so the assertion holds regardless of opkg's move-vs-copy
# behavior in any given version.
@test "publish_package never runs opkg from the source path" {
  local src="$BATS_TEST_TMPDIR/pkg"
  _make_fixture "$src"

  local cwd_log="$BATS_TEST_TMPDIR/opkg-cwd.log"
  export CWD_LOG="$cwd_log"

  run bash -euo pipefail -c '
    source <('"$(declare -f _publish_helpers)"'; _publish_helpers)
    opkg() { pwd -P >>"$CWD_LOG"; return 0; }
    opkg_installed() { return 1; }
    exit_code=0
    publish_package fixturepkg "'"$src"'"
  '
  assert_success

  # opkg was invoked, and never from a path resolving to the live source
  assert_file_exist "$cwd_log"
  local resolved_src
  resolved_src="$(cd "$src" && pwd -P)"
  run cat "$cwd_log"
  refute_output --partial "$resolved_src"
}

# Direct behavioral guard: the sentinel resource must survive publish_package.
# opkg is mocked to emulate the destructive move (delete source resources),
# proving the copy-first fix protects the source even against move semantics.
@test "publish_package preserves source resources against a moving opkg" {
  local src="$BATS_TEST_TMPDIR/pkg"
  _make_fixture "$src"

  run bash -euo pipefail -c '
    source <('"$(declare -f _publish_helpers)"'; _publish_helpers)
    # emulate a move-on-publish opkg: wipe resources under the publish CWD
    opkg() {
      case "$1" in
        publish) find . -type f ! -name openpackage.yml -delete ;;
      esac
      return 0
    }
    opkg_installed() { return 1; }
    exit_code=0
    publish_package fixturepkg "'"$src"'"
  '
  assert_success
  assert_file_exist "$src/skills/foo/SKILL.md"
  run cat "$src/skills/foo/SKILL.md"
  assert_output "SENTINEL"
}

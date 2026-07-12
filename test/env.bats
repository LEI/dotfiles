setup() {
  # shellcheck source=test/common/setup.sh
  source test/common/setup.sh
  _common_setup

  # shellcheck source=test/common/helper.sh
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

# Print PATH on failure to surface the env the test actually saw.
diag_path() {
  printf 'PATH:\n' >&3
  printf '%s\n' "$PATH" | tr : '\n' | sed 's/^/  /' >&3
}

@test "path: mise shims or install dirs reachable" {
  check_feature mise
  # An active nix devShell wins over mise shims by design, so the shims may be
  # demoted or absent; the devShell provides the pinned tools instead
  case ":$PATH:" in
  *:/nix/store/*)
    [ -n "${IN_NIX_SHELL:-}" ] && skip "active nix devShell provides pinned tools"
    ;;
  esac
  if ! command -v mise >/dev/null; then
    diag_path
    fail "mise binary not in PATH"
  fi
  shims="$HOME/.local/share/mise/shims"
  case ":$PATH:" in
  *:"$shims":*) ;;
  *:*/.local/share/mise/installs/*:*) ;;
  *)
    diag_path
    fail "neither mise shims ($shims) nor install dirs are in PATH"
    ;;
  esac
}

@test "path: brew bin reachable" {
  check_feature brew
  if ! command -v brew >/dev/null; then
    diag_path
    fail "brew binary not in PATH"
  fi
  brew_bin="$(brew --prefix)/bin"
  case ":$PATH:" in
  *:"$brew_bin":*) ;;
  *)
    diag_path
    fail "brew bin ($brew_bin) not in PATH"
    ;;
  esac
}

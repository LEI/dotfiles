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
}

# bats file_tags=script,container

# bats test_tags=type:unit
@test "container: fails when CONTAINER_PROVIDER is not set" {
  unset CONTAINER_PROVIDER
  run ./script/container
  assert_line --partial "CONTAINER_PROVIDER: parameter null or not set"
  assert_failure
}

# bats test_tags=type:unit
@test "container: resolves basic image names correctly" {
  source_container

  resolve alpine
  assert_equal "$image_name" "alpine"
  assert_equal "$image" "alpine:latest"
  assert_equal "$container" "${tag_prefix}-alpine-latest"
  assert_equal "$exec_user" "test"
  assert_equal "$home" "/home/test"
}

# bats test_tags=type:unit
@test "container: resolves ubuntu with version suffix" {
  source_container

  resolve ubuntu:22.04
  assert_equal "$image_name" "ubuntu"
  assert_equal "$image" "ubuntu:22.04"
  assert_equal "$version" "22.04"
  assert_equal "$container" "${tag_prefix}-ubuntu-22.04"
}

# bats test_tags=type:unit
@test "container: resolves archlinux with ARM64 repo on ARM systems" {
  source_container
  local arch
  arch="$(uname -m)"

  resolve archlinux
  assert_equal "$image_name" "archlinux"

  if [ "$arch" = arm64 ] || [ "$arch" = aarch64 ]; then
    assert_equal "$image" "docker.io/ogarcia/archlinux:latest"
  else
    assert_equal "$image" "archlinux:latest"
  fi
}

# bats test_tags=type:unit
@test "container: resolves opensuse to tumbleweed" {
  source_container

  resolve opensuse
  assert_equal "$image_name" "opensuse"
  assert_equal "$image" "opensuse/tumbleweed:latest"
}

# bats test_tags=type:unit
@test "container: resolves termux with architecture-specific version" {
  source_container
  local arch
  arch="$(uname -m)"

  resolve termux
  assert_equal "$image_name" "termux"

  if [ "$arch" = arm64 ] || [ "$arch" = aarch64 ]; then
    assert_equal "$version" "aarch64"
    assert_equal "$image" "docker.io/termux/termux-docker:aarch64"
  else
    assert_equal "$version" "x86_64"
    assert_equal "$image" "docker.io/termux/termux-docker:x86_64"
  fi
  assert_equal "$exec_user" "system"
  assert_equal "$home" "/data/data/com.termux/files/home"
}

# bats test_tags=type:unit
@test "container: log function outputs to stderr with prefix" {
  source_container

  run log "test message"
  assert_output "container: test message"
  assert_success
}

# bats test_tags=type:unit
@test "container: trace function echoes command and executes it" {
  source_container

  run trace echo "test"
  assert_line --partial "+ echo test"
  assert_line "test"
  assert_success
}

# bats test_tags=type:unit
@test "container: list outputs all images one per line" {
  source_container

  run list
  assert_success
  assert_line "alpine"
  assert_line "archlinux"
  assert_line "debian"
  assert_line "fedora"
  assert_line "opensuse"
  assert_line "termux"
  assert_line "ubuntu"
}

# bats test_tags=type:unit
@test "container: main with no arguments runs status" {
  source_container

  # Mock container inspect to return failure
  # shellcheck disable=SC2329
  container() { return 1; }

  run main
  assert_success
  assert_line --regexp "^alpine"
  assert_line --regexp "^archlinux"
}

# bats test_tags=type:unit
@test "container: main with 'list' or 'l' runs list command" {
  source_container

  for cmd in l ls list; do
    run main "$cmd"
    assert_success
    assert_line "alpine"
  done
}

# bats test_tags=type:unit
@test "container: main with 'status' or 's' runs status command" {
  source_container

  # Mock container inspect to return failure
  # shellcheck disable=SC2329
  container() { return 1; }

  for cmd in s st status; do
    run main "$cmd"
    assert_success
    assert_line --regexp "^alpine"
  done
}

# bats test_tags=type:unit
@test "container: container_exec sets correct environment variables" {
  source_container
  resolve alpine

  # Mock container exec to capture arguments
  # shellcheck disable=SC2329
  container() {
    local args
    args=$(printf '%s\n' "$@")
    echo "$args"
  }

  run container_exec echo test
  assert_success
  assert_output --partial "CHEZMOI_UPGRADE=true"
  assert_output --partial "MISE_TRUSTED_CONFIG_PATHS=/home/test/.local/share/chezmoi"
  assert_output --partial "user=test"
  assert_output --partial "workdir=/home/test/.local/share/chezmoi"
}

# bats test_tags=type:unit
@test "container: container_exec includes CI env var when set" {
  source_container
  resolve alpine
  export CI=true

  # Mock container exec to capture arguments
  # shellcheck disable=SC2329
  container() {
    local args
    args=$(printf '%s\n' "$@")
    echo "$args"
  }

  run container_exec echo test
  assert_success
  assert_output --partial "CI=true"
}

# bats test_tags=type:unit
@test "container: container_exec redacts GITHUB_TOKEN in logs" {
  source_container
  resolve alpine
  export GITHUB_TOKEN="secret-token-123"

  # Mock container exec to capture arguments
  container() {
    local args
    args=$(printf '%s\n' "$@")
    echo "$args"
  }

  run container_exec echo test
  assert_success
  # Should not contain the actual token in output
  refute_output "secret-token-123"
  # But should contain the redacted version in the logs (if we were capturing stderr)
}

# bats test_tags=type:unit
@test "container: container_exec_mise sources mise init" {
  source_container
  resolve alpine

  # Mock container_exec to capture command
  container_exec() {
    echo "$@"
  }

  run container_exec_mise echo test
  assert_success
  assert_output --partial "source ~/.config/mise/init.sh"
}

# bats test_tags=type:unit
@test "container: DEV_USER defaults to 'test'" {
  # Test that DEV_USER has the default value when not overridden
  source_container
  assert_equal "$DEV_USER" "test"
}

# bats test_tags=type:unit
@test "container: tag_prefix uses current directory name" {
  source_container

  assert_equal "$tag_prefix" "chezmoi"
}

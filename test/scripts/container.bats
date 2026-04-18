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
  for name in $images; do
    assert_line "$name"
  done
}

# bats test_tags=type:unit
@test "container: main routes list aliases to list" {
  source_container
  for cmd in l ls list; do
    run main "$cmd"
    assert_success
    assert_line "alpine"
  done
}

# bats test_tags=type:unit
@test "container: main routes status aliases to status" {
  source_container
  # stub container inspect to report no containers exist
  # shellcheck disable=SC2329
  container() { return 1; }
  for cmd in "" s st status; do
    run main $cmd
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
  # shellcheck disable=SC2329
  container() {
    local args
    args=$(printf '%s\n' "$@")
    echo "$args"
  }

  run container_exec echo test
  assert_success
  # Should not contain the actual token in output
  refute_output "secret-token-123"
}

# bats test_tags=type:unit
@test "container: container_exec_mise sources mise init" {
  source_container
  resolve alpine

  # Mock container_exec to capture command
  # shellcheck disable=SC2329
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

# bats test_tags=type:unit
@test "container: resolve image matrix" {
  source_container
  # format: "image exec_user home"
  local arch
  arch="$(uname -m)"
  local archlinux_repo=archlinux
  if [ "$arch" = arm64 ] || [ "$arch" = aarch64 ]; then
    archlinux_repo=docker.io/ogarcia/archlinux
  fi
  local termux_version=x86_64
  if [ "$arch" = arm64 ] || [ "$arch" = aarch64 ]; then
    termux_version=aarch64
  fi
  declare -A matrix=(
    [alpine]="alpine:latest test /home/test"
    [archlinux]="$archlinux_repo:latest test /home/test"
    [debian]="debian:latest test /home/test"
    [fedora]="fedora:latest test /home/test"
    [opensuse]="opensuse/tumbleweed:latest test /home/test"
    [termux]="docker.io/termux/termux-docker:$termux_version system /data/data/com.termux/files/home"
    [ubuntu]="ubuntu:latest test /home/test"
  )
  for name in $images; do
    resolve "$name"
    read -r exp_image exp_exec_user exp_home <<<"${matrix[$name]}"
    assert_equal "$image_name" "$name"
    assert_equal "$image" "$exp_image"
    assert_equal "$exec_user" "$exp_exec_user"
    assert_equal "$home" "$exp_home"
    assert [ -n "$container" ]
    assert [ -n "$chezmoi_root" ]
  done
}

# bats test_tags=type:unit
@test "container: resolve version suffix" {
  source_container
  resolve alpine:3.19

  assert_equal "$image_name" alpine
  assert_equal "$image" alpine:3.19
  assert_equal "$container" "${tag_prefix}-alpine-3.19"
}

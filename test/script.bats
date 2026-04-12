# shellcheck disable=SC2154

setup_file() {
  source test/common/setup-file.sh
  _common_setup_file

  export BATS_NO_PARALLELIZE_WITHIN_FILE=true
  export DRY_RUN=true
}

setup() {
  source test/common/setup.sh
  _common_setup

  source test/common/helper.sh
}

# bats file_tags=script

# bats test_tags=bootstrap,type:unit
@test "script/bootstrap" {
  local chezmoi_args=(
    "--dry-run"
    "--refresh-externals=never"
  )
  export CI=true
  run_script ./script/bootstrap "${chezmoi_args[@]}"

  refute_output --regexp "Tip:"
  assert_stderr_line "DRY-RUN: Running 'chezmoi init --apply --source=$PWD ${chezmoi_args[*]}'"
  assert_success
}

# bats test_tags=startup,type:unit
@test "script/startup" {
  export BENCH_ITERATIONS=1
  export SHELL=dummy
  stub_seq dummy $((BENCH_ITERATIONS + 2))
  run_script ./script/startup
  unstub dummy 2>/dev/null || true

  assert_stderr_line --regexp "startup 1/$BENCH_ITERATIONS: dummy -ci exit"
  assert_success
  jq . <<<"$output" >/dev/null
}

# bats test_tags=check,type:unit
# @test "script/check" {
#   stub_seq goss 1
#   stub_seq mise 1
#   stub_seq nvim 1
#   run_script ./script/check
#   unstub goss 2>/dev/null || true
#   unstub mise 2>/dev/null || true
#   unstub nvim 2>/dev/null || true
#
#   if has_feature goss; then
#     assert_stderr_line "Checking goss"
#   fi
#   if has_feature mise; then
#     assert_stderr_line "Checking mise"
#   fi
#   if has_feature neovim; then
#     assert_stderr_line "Checking nvim"
#   fi
#   assert_success
# }

# bats test_tags=container,type:unit
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

# bats test_tags=container,type:unit
@test "container: resolve version suffix" {
  source_container
  resolve alpine:3.19

  assert_equal "$image_name" alpine
  assert_equal "$image" alpine:3.19
  assert_equal "$container" "${tag_prefix}-alpine-3.19"
}

# bats test_tags=container,type:unit
@test "container: runtime wrapper delegates to CONTAINER_PROVIDER" {
  source_container
  stub docker 'echo docker-called: $@'
  export CONTAINER_PROVIDER=docker
  run container version
  assert_output "docker-called: version"
  unstub docker
}

# bats test_tags=container,type:unit
@test "container: list prints one name per line" {
  source_container
  run list
  assert_success
  for name in $images; do
    assert_line "$name"
  done
  # refute_output --regexp $'\t| '
}

# bats test_tags=container,type:unit
@test "container: main routes list aliases to list" {
  source_container
  for cmd in l ls list; do
    run main "$cmd"
    assert_success
    assert_line "alpine"
  done
}

# bats test_tags=container,type:unit
@test "container: main routes status aliases to status" {
  source_container
  # stub container inspect to report no containers exist
  container() { return 1; }
  for cmd in "" s st status; do
    run main $cmd
    assert_success
    assert_line --regexp "^alpine"
  done
}

# bats test_tags=install,type:unit
@test "install-password-manager: skips on unknown command" {
  export CHEZMOI_COMMAND=test
  export CHEZMOI_WORKING_TREE="$PWD"
  run_script home/.install-password-manager.sh

  refute_output
  refute_stderr
  assert_success
}

# bats test_tags=install,type:unit
@test "install-password-manager: exits if already installed" {
  stub bws "true"
  export CHEZMOI_COMMAND=apply
  export CHEZMOI_WORKING_TREE="$PWD"
  run_script home/.install-password-manager.sh
  unstub bws 2>/dev/null || true

  refute_output
  refute_stderr
  assert_success
}

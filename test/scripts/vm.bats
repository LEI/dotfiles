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

source_vm() {
  export VM_PROVIDER="${VM_PROVIDER:-tart}"
  export XDG_CONFIG_HOME="$PWD/home/dot_config"
  # shellcheck source=script/vm
  source ./script/vm
  dirs=""
  image=test-image
  name=test-vm
  keep=false
  tmux=false
  verbosity=1
}

# bats file_tags=script,vm

# bats test_tags=type:unit
@test "vm_mount: skips when dirs is empty" {
  source_vm
  run vm_mount
  assert_success
  refute_output
}

# bats test_tags=type:unit
@test "vm_mount: warns on non-tart provider" {
  export VM_PROVIDER=vetu
  source_vm
  dirs="foo:/bar"
  run vm_mount
  assert_success
  assert_line --partial "does not support host directory sharing"
}

# bats test_tags=type:unit
@test "vm_mount: name:path entry uses prefix as tag" {
  source_vm
  dirs="myname:/host/path"
  # shellcheck disable=SC2329
  tart() { echo "$@"; }
  run vm_mount
  assert_success
  assert_line --partial "mount -t virtiofs myname"
}

# bats test_tags=type:unit
@test "vm_mount: bare path uses basename as tag" {
  source_vm
  dirs="/host/path/chezmoi"
  # shellcheck disable=SC2329
  tart() { echo "$@"; }
  run vm_mount
  assert_success
  assert_line --partial "mount -t virtiofs chezmoi"
}

setup() {
  source test/common/setup.sh
  _common_setup

  source test/common/helper.sh
}

# bats file_tags=dotfiles,home

@test "macos: script exists and is executable" {
  [ "$UNAME" = Darwin ] || skip "$UNAME"
  # [ -f ~/.macos ]
  [ -x ~/.macos ]
}

# @test "brew installation script runs without errors" {
#   run bash install/macos/common/brew.sh
#   [ "$status" -eq 0 ]
# }
#
# @test "brew command is available after installation" {
#   run command -v brew
#   [ "$status" -eq 0 ]
# }

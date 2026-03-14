setup() {
  source test/common/setup.sh
  _common_setup

  source test/common/helper.sh
}

# bats file_tags=home,type:smoke

@test "macos: script exists and is executable" {
  [ "$UNAME" = Darwin ] || skip "$UNAME"
  [ -x ~/.macos ]
}

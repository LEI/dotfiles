# #!/usr/bin/env bash

# Seil.app
# https://pqrs.org/osx/karabiner/seil.html.en

# System Preferences > Keyboard > Modifier Keys... Caps Lock Ket -> No Action

cli=/Applications/Seil.app/Contents/Library/bin/seil

# /bin/echo -n .

$cli set enable_capslock 1
echo "enable_capslock 1"

# 53: Escape
# 80: F19
$cli set keycode_capslock 53
echo "keycode_capslock 53"

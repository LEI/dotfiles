# Editor
export EDITOR
if hash nvim 2>/dev/null; then
  EDITOR="nvim"
else
  EDITOR="vim -f"
fi

# Change default location of Homebrew Cask applications
export HOMEBREW_CASK_OPTS="--appdir=/Applications" #--caskroom=/etc/Caskroom

# Editor
export EDITOR="vim -f"

# Gems install path (already exported?)
export GEM_HOME="$(ruby -e 'print Gem.user_dir')"

# Change default location of Homebrew Cask applications
export HOMEBREW_CASK_OPTS="--appdir=/Applications" #--caskroom=/etc/Caskroom

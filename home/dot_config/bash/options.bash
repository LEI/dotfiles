# Prevent file overwrite on stdout redirection
# Use `>|` to force redirection to an existing file
set -o noclobber

# Autocorrect minor typos in cd
shopt -s cdspell

# Update LINES/COLUMNS after each command
shopt -s checkwinsize

# Extended pattern matching: !(x), ?(x), +(x), @(x), *(x)
shopt -s extglob

# Preserve newlines in multi-line history
# shopt -s lithist

# Case-insensitive globbing
shopt -s nocaseglob

# Include dotfiles in globbing and completion
shopt -s dotglob

# Bash 4+ options
if ((BASH_VERSINFO[0] >= 4)); then
  # cd into directory names typed as commands
  shopt -s autocd

  # Autocorrect minor typos in directory names
  shopt -s dirspell

  # Recursive globbing with **
  shopt -s globstar
fi

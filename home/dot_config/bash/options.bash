# Prevent file overwrite on stdout redirection
# Use `>|` to force redirection to an existing file
set -o noclobber

shopt -s cdspell
shopt -s checkwinsize
shopt -s cmdhist
shopt -s extglob
shopt -s histappend
shopt -s histreedit
shopt -s histverify
# shopt -s lithist
shopt -s nocaseglob

# Bash 4+ options
if ((BASH_VERSINFO[0] >= 4)); then
  shopt -s autocd
  shopt -s dirspell
  shopt -s globstar
fi

# Prevent file overwrite on stdout redirection
# Use `>|` to force redirection to an existing file
set -o noclobber

shopt -s autocd
shopt -s cdspell
shopt -s checkwinsize
shopt -s cmdhist
shopt -s dirspell
shopt -s extglob
shopt -s globstar
shopt -s histappend
shopt -s histreedit
shopt -s histverify
# shopt -s lithist
shopt -s nocaseglob

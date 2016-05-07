#
# Bash options
#

# Case-insensitive globbing (used in pathname expansion)
shopt -s nocaseglob

# Autocorrect typos in path names when using 'cd'
shopt -s cdspell

# Enable some Bash 4 features when possible:
#   'autocd', e.g. '**/qux' will enter './foo/bar/baz/qux'
#   Recursive globbing, e.g. 'echo **/*.txt'
for option in autocd globstar; do
  shopt -s "$option" 2> /dev/null
done
unset option

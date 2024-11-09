# Prevent file overwrite on stdout redirection
# Use `>|` to force redirection to an existing file
set -o noclobber

main() {
  local option
  for option in autocd cdspell checkwinsize cmdhist dirspell extglob globstar histappend nocaseglob; do
    shopt -s "$option" 2>/dev/null
  done
}

main "$@"
unset main

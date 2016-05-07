#
# Append or prepend to PATH
#

# Prevent duplicate directories in the PATH variable
# /dev/null 2>&1
if ! type pathmunge &>/dev/null; then
  pathmunge() {
    if ! [[ $PATH =~ (^|:)$1($|:) ]]; then
      if [[ "$2" == "after" ]]; then
        # pathmunge /path/to/dir after
        PATH=$PATH:$1
      else
        # pathmunge /path/to/dir
        PATH=$1:$PATH
      fi
    fi
  }
fi

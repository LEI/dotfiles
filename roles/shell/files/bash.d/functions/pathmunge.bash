# Append or prepend to PATH

if ! hash pathmunge 2>/dev/null; then
  pathmunge() {
    local p="$1"
    local pos="$2"
    if [[ ! -d "$p" ]]; then
      # Not a directory
      return 1
    fi
    if [[ $PATH =~ (^|:)$p($|:) ]]; then
      # Already in PATH
      return
    fi
    if [[ "$pos" == "after" ]]; then
      # pathmunge /path/to/dir after
      PATH=$PATH:$p
    else
      # pathmunge /path/to/dir
      PATH=$p:$PATH
    fi
  }
fi

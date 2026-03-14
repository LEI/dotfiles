if [ -d "${XDG_DATA_HOME:-$HOME/.local/share}/nvim/mason/bin" ]; then
  pathmunge "${XDG_DATA_HOME:-$HOME/.local/share}/nvim/mason/bin" after
fi

if command -v nvim >/dev/null; then
  alias dbui="nvim +DBUI"
fi

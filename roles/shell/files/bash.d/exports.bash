# Exports

if hash nvim 2>/dev/null; then
  EDITOR="nvim"
else
  EDITOR="vim -f"
fi

export EDITOR

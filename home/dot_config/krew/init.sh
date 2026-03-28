if [ -n "$KREW_ROOT" ] && [ -d "$KREW_ROOT/bin" ]; then
  pathmunge "$KREW_ROOT/bin" after
fi

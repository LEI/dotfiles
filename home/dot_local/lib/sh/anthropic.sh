# shellcheck shell=sh

# anthropic_quota_label <key>
# Maps an Anthropic usage API response key to a display label.
# Any seven_day_<name> key not in the override table renders as
# "7d <name with underscores as spaces>"; other unknown keys pass through as-is
anthropic_quota_label() {
  case "$1" in
  five_hour) printf '5h quota' ;;
  seven_day) printf '7d all models' ;;
  seven_day_omelette) printf '7d design' ;;
  omelette_promotional) printf 'design promo' ;;
  seven_day_*)
    name=${1#seven_day_}
    printf '7d %s' "$(printf '%s' "$name" | tr '_' ' ')"
    ;;
  *) printf '%s' "$1" ;;
  esac
}

# anthropic_scope_prefix <group>
# Maps a limits[] entry's group field to a duration prefix for per-model
# quota rows: session -> 5h, weekly -> 7d; unknown groups pass through as-is
anthropic_scope_prefix() {
  case "$1" in
  session) printf '5h' ;;
  weekly) printf '7d' ;;
  *) printf '%s' "$1" ;;
  esac
}

# Sources ~/.config/environment.d/*.conf; simulates systemd environment.d(5) for non-systemd shells
XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
__env_d="${XDG_CONFIG_HOME}/environment.d"
if [ -d "$__env_d" ]; then
  # nullglob: silently skip if no *.conf files exist (zsh fails the glob otherwise)
  [ -n "${ZSH_VERSION:-}" ] && setopt nullglob
  for __f in "${__env_d}/"*.conf; do
    if [ -f "$__f" ]; then
      set -a
      # shellcheck source=/dev/null
      . "$__f"
      set +a
    fi
  done
  [ -n "${ZSH_VERSION:-}" ] && unsetopt nullglob
fi
unset __env_d __f

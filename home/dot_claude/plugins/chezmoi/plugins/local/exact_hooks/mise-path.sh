#!/bin/sh

# Claude-scoped PATH, not the global shell: resolves project-pinned mise tools
# Skip inside an active nix devShell so its pinned tools are not shadowed. Require
# both the IN_NIX_SHELL sentinel and a real /nix/store PATH entry, so a spoofed
# bare IN_NIX_SHELL from a hostile env cannot demote tools.
in_devshell=
case ":$PATH:" in
*:/nix/store/*)
  [ -n "${IN_NIX_SHELL:-}" ] && in_devshell=1
  ;;
esac

if [ -z "$in_devshell" ]; then
  # shellcheck disable=SC2016
  echo 'export PATH="$HOME/.local/share/mise/shims:$PATH"' >>"$CLAUDE_ENV_FILE"
fi

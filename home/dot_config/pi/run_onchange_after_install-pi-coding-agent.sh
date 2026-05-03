#!/bin/sh

# https://github.com/badlogic/pi-mono/tree/main/packages/coding-agent/examples/extensions/subagent#installation

set -eu

PI_CONFIG_DIR="${PI_CONFIG_DIR:-$XDG_CONFIG_HOME/pi}"
PI_CODING_AGENT_DIR="${PI_CODING_AGENT_DIR:-$XDG_CONFIG_HOME/pi-coding-agent}"

lib_dir="$CHEZMOI_WORKING_TREE/home/dot_local/lib"
# shellcheck source=home/dot_local/lib/sh/log.sh
. "$lib_dir/sh/log.sh"
# shellcheck source=home/dot_local/lib/sh/run.sh
. "$lib_dir/sh/run.sh"

# Symlink agents
if [ ! -d "$PI_CODING_AGENT_DIR/agents" ]; then
  run mkdir -p "$PI_CODING_AGENT_DIR/agents"
fi
for f in "$PI_CONFIG_DIR/agent/extensions/subagent/agents/"*.md; do
  # run ln -sf "$f" "$PI_CODING_AGENT_DIR/agents/${f##*/}"
  run ln -sf "../extensions/subagent/agents/${f##*/}" "$PI_CODING_AGENT_DIR/agents/${f##*/}"
done

# Symlink workflow prompts
if [ ! -d "$PI_CODING_AGENT_DIR/prompts" ]; then
  run mkdir -p "$PI_CODING_AGENT_DIR/prompts"
fi
for f in "$PI_CODING_AGENT_DIR/extensions/subagent/prompts/"*.md; do
  # run ln -sf "$f" "$PI_CODING_AGENT_DIR/prompts/${f##*/}"
  run ln -sf "../extensions/subagent/prompts/${f##*/}" "$PI_CODING_AGENT_DIR/prompts/${f##*/}"
done

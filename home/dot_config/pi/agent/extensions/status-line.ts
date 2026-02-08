/**
 * Status Line Extension
 *
 * Demonstrates ctx.ui.setStatus() for displaying persistent status text in the footer.
 * Shows turn progress with themed colors.
 */

import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";

export default function(pi: ExtensionAPI) {
  // https://github.com/badlogic/pi-mono/blob/main/packages/coding-agent/examples/extensions/status-line.ts
  /* let turnCount = 0;

  pi.on("session_start", async (_event, ctx) => {
    const theme = ctx.ui.theme;
    ctx.ui.setStatus("status-demo", theme.fg("dim", "Ready"));
  });

  pi.on("turn_start", async (_event, ctx) => {
    turnCount++;
    const theme = ctx.ui.theme;
    const spinner = theme.fg("accent", "●");
    const text = theme.fg("dim", ` Turn ${turnCount}...`);
    ctx.ui.setStatus("status-demo", spinner + text);
  });

  pi.on("turn_end", async (_event, ctx) => {
    const theme = ctx.ui.theme;
    const check = theme.fg("success", "✓");
    const text = theme.fg("dim", ` Turn ${turnCount} complete`);
    ctx.ui.setStatus("status-demo", check + text);
  });

  pi.on("session_switch", async (event, ctx) => {
    if (event.reason === "new") {
      turnCount = 0;
      const theme = ctx.ui.theme;
      ctx.ui.setStatus("status-demo", theme.fg("dim", "Ready"));
    }
  }); */

  // https://github.com/badlogic/pi-mono/blob/main/packages/coding-agent/examples/extensions/model-status.ts
  /* pi.on("model_select", async (event, ctx) => {
    const { model, previousModel, source } = event;

    // Format model identifiers
    const next = `${model.provider}/${model.id}`;
    const prev = previousModel ? `${previousModel.provider}/${previousModel.id}` : "none";

    // Show notification on change
    if (source !== "restore") {
      ctx.ui.notify(`Model: ${next}`, "info");
    }

    // Update status bar with current model
    ctx.ui.setStatus("model", `🤖 ${model.id}`);

    // Log change details (visible in debug output)
    console.log(`[model_select] ${prev} → ${next} (${source})`);
  }); */
}

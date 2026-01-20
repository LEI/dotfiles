import type { Plugin } from "@opencode-ai/plugin"

// https://opencode.ai/docs/plugins/#env-protection
export const EnvProtection: Plugin = async ({ project, client, $, directory, worktree }) => {
  return {
    "tool.execute.before": async (input, output) => {
      if (input.tool === "read" && output.args.filePath.includes(".env")) {
        const message = "Do not read .env files"
        await client.app.log({
          service: "env-protection",
          level: "error",
          message,
          extra: { file: output.args.filePath },
        })
        throw new Error(message)
      }
    },
  }
}

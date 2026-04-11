import type { Plugin } from "@opencode-ai/plugin"

export const ShellEnv: Plugin = async () => {
  return {
    "shell.env": async (input, output) => {
      // output.env.MY_API_KEY = "secret"
      // output.env.PROJECT_ROOT = input.cwd
    },
  }
}

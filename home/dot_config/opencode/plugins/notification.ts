import { type Plugin, tool } from "@opencode-ai/plugin"

// https://opencode.ai/docs/plugins/#send-notifications
export const NotificationPlugin: Plugin = async ({ project, client, $, directory, worktree }) => {
  return {
    event: async ({ event }) => {
      // Send notification on session completion
      if (event.type === "session.idle") {
        // await $`osascript -e 'display notification "Session completed!" with title "opencode"'`
        await $`notify-send "opencode" "Session completed!"`
      }
    },
    tool: {
      mytool: tool({
        description: "Send a notification",
        args: {
          title: tool.schema.string(),
          message: tool.schema.string(),
        },
        async execute(args, ctx) {
          return $`notify-send ${args.title} ${args.message}`.text()
        },
      }),
    },
  }
}

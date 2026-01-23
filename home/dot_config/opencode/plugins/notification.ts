import { type Plugin, tool } from "@opencode-ai/plugin"

// https://opencode.ai/docs/plugins/#send-notifications
export const NotificationPlugin: Plugin = async ({ project, client, $, directory, worktree }) => {
  function notify(title: string, message: string) {
    if (process.platform === "darwin") {
      $`osascript -e 'display notification "${message}" with title "${title}"'`
    } else {
      $`notify-send "${title}" "${message}"`
    }
  }
  return {
    event: async ({ event }) => {
      // Send notification on session completion
      if (event.type === "session.idle") {
        notify("opencode", "Session completed!")
      }
    },
    tool: {
      notify: tool({
        description: "Send a notification",
        args: {
          title: tool.schema.string(),
          message: tool.schema.string(),
        },
        async execute(args, ctx) {
          return notify(args.title, args.message)
        },
      }),
    },
  }
}

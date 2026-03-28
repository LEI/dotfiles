import { type Plugin, tool } from "@opencode-ai/plugin"

// https://opencode.ai/docs/plugins/#send-notifications
export const NotificationPlugin: Plugin = async ({ project, client, $, directory, worktree }) => {
  async function notify(title: string, message: string) {
    await client.app.log({
      service: "notification",
      level: "info",
      message: "Sending notification",
      extra: { title, message },
    })
    if (process.platform === "darwin") {
      return $`osascript -e 'display notification "${message}" with title "${title}"'`
    }
    return $`notify-send "${title}" "${message}"`
  }
  return {
    /* event: async ({ event }) => {
      await client.app.log({
        service: "notification",
        level: "debug",
        message: "Event received",
        extra: { event },
      })
      // Send notification on session completion
      if (event.type === "session.idle") {
        await notify("opencode", "Session completed!")
      }
    }, */
    tool: {
      notify: tool({
        description: "Send a notification",
        args: {
          title: tool.schema.string(),
          message: tool.schema.string(),
        },
        async execute(args, context) {
          // const { agent, sessionID, messageID } = context
          // `Agent: ${agent}, Session: ${sessionID}, Message: ${messageID}`
          return notify(args.title, args.message)
        },
      }),
    },
  }
}

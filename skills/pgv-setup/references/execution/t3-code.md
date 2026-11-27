# T3 Code build session

Use this guide when the caller is already a T3 Code thread. T3 hosts
the two threads. Each thread has its own underlying provider and model.

## Launch

1. Use the assigned T3 project and environment. Resolve the build model
   and effort to a configured provider instance. Recommend the caller's
   provider first. Use the same T3 launch and messaging tools for
   same-provider and cross-provider threads.
2. Call the in-thread `t3_thread_launch` tool to create an ordinary
   top-level thread. Set `modelSelection` using the provider instance,
   model, and effort options T3 exposes. Bind the worktree before the
   agent starts:

   ```json
   {
     "type": "worktree",
     "baseRef": "<approved local base ref>",
     "startFromOrigin": false
   }
   ```

   Use that object as `workspaceStrategy` for a local base. Use the
   actual approved ref and the matching origin setting. Resolve provider
   and effort options using the current T3 tool schema.
3. Start with a short bootstrap `message` that holds implementation.
   Keep the returned `threadId` and `link`. Verify the thread's provider,
   effort, and worktree. Include the caller ID and actual worktree in
   the approved build brief and send it to that thread.
   [T3 launch tool schema](https://github.com/pingdotgg/t3code/blob/main/apps/server/src/mcp/toolkits/project/tools.ts#L129)

## Exchange messages

Use `t3_thread_send` with the other T3 thread's `threadId` and
`mode: "queue"` for the brief, review requests, verdicts, decisions,
and results.
Reuse each thread ID through the build. Give each send a distinct
`clientRequestId` and reuse it if retrying the same message. Use
`t3_thread_read` to verify delivery when needed. The user can open
either thread from its T3 link or the sidebar.

Handle any message authorization request in the thread that asks for it.

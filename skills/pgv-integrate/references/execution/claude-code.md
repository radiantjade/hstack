# Claude Code execution

Use the assigned model, effort, checkout, and access from
[model routing](../model-routing.md).

## CLI

### Build session

Start a named interactive background session from the build worktree.

```bash
claude --bg --name "$name" --model "$model" --effort "$effort" \
  --permission-mode "$permission_mode" "$brief"
```

Use the caller's permission mode and keep the returned session ID.
The user can open the session with `claude attach <id>`. Exchange messages
through the native session tools. Start an exchange by session name, then
reply through the sender of each message. If an idle session has stopped,
run `claude respawn <id>` and retry the message. The user answers any
approval required to message across permission modes.

### Generator and Validator

Start a fresh non-interactive invocation for each packet.

```bash
claude -p --model "$model" --effort "$effort" "$packet"
```

Apply the role's permissions. If the role cannot write its report file,
capture the completed report from the response and save it verbatim.
[Claude Code CLI reference](https://code.claude.com/docs/en/cli-reference)

## GUI

### Build session

1. Use Claude Code desktop's native session tool to start a named
   session with the assigned model and the caller's permission mode.
   Select the assigned worktree or let the app create it from the target.
2. If the assigned effort is higher than the caller's and the app starts
   at the caller's effort or lower, start with a wait instruction, set
   the effort with the session tool, and confirm the model and effort
   before sending the brief. An effort change applies from the next turn.
3. Exchange review requests, verdicts, and decisions through the native
   session tools. The user answers any app approval request.

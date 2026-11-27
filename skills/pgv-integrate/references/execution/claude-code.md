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

Start a fresh non-interactive invocation for each packet. Choose the
session ID before the turn and record it, so that it is known even if the
turn is cut.

```bash
session_id="$(uuidgen | tr 'A-Z' 'a-z')"
claude -p --session-id "$session_id" --model "$model" --effort "$effort" "$packet"
```

Apply the role's permissions. If the role cannot write its report file,
capture the completed report from the response and save it verbatim.
[Claude Code CLI reference](https://code.claude.com/docs/en/cli-reference)

**Resume an interrupted turn** (see
[model routing](../model-routing.md#an-interrupted-turn)), from the same
checkout and with the same model, effort, and permissions:

```bash
claude -p --resume "$session_id" --model "$model" --effort "$effort" "$resume_prompt"
```

With `--output-format json` the result also carries `session_id`. A turn
started with `--no-session-persistence` cannot be resumed. Tested with
Claude Code 2.1.332 on macOS.

## GUI

### Build session

1. Tell the user the assigned model, effort, worktree, and caller's
   permission mode. Call `start_session` with `initiation: "offer"`
   and the build title. In the card's **Options**, the user selects
   those values before clicking **New session**. **Extra high** is `xhigh`.
2. After acceptance, send the build brief with `start_session` using
   the returned `proposal_id`, `prompt`, and `background`. The brief
   starts the first turn. If the card cannot target the assigned worktree
   or expose the assigned settings, give the brief to the user. They
   open a fresh Code tab session in that worktree, select the assigned
   settings, and send the brief as the first message.
3. When the build transcript is available, verify `message.model` and
   `effort` on the first assistant record. Pause the build if either
   differs from the assignment. Exchange review requests, verdicts, and
   decisions through the native session tools using the Desktop session
   IDs. The user answers any app approval request.

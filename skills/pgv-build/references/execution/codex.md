# Codex execution

Use the assigned model, effort, checkout, and access from
[model routing](../model-routing.md).

## CLI

### Build session

Use the caller's native session creation capability to open an
interactive session in the assigned worktree. Include the caller's thread
ID in the brief. For a shell route to an existing thread, deliver a
message with:

```bash
codex queue --thread "$thread_id" --resume --message "$text"
```

Confirm delivery before continuing. If the host cannot create and reach
an interactive session, report the missing capability.

### Generator and Validator

Start a fresh non-interactive invocation for each packet.

```bash
codex exec -m "$model" -c "model_reasoning_effort=\"$effort\"" "$packet"
```

Apply the role's permissions. If the Validator cannot write its report
file, capture the completed report from the response and save it verbatim.

Record the session ID of each turn. With `--json`, the first event
(`thread.started`) carries it as `thread_id`, before the turn ends.

**Resume an interrupted turn** (see
[model routing](../model-routing.md#an-interrupted-turn)), from the same
checkout and with the same model, effort, and permissions:

```bash
codex exec resume -m "$model" -c "model_reasoning_effort=\"$effort\"" \
  "$session_id" "$resume_prompt"
```

`codex exec resume --last` takes the most recent session recorded for the
checkout; use the ID when several turns ran there. A turn started with
`--ephemeral` cannot be resumed. Tested with `codex-cli` 0.172.0 on macOS.

## GUI

### Build session

Use the app's native thread creation and messaging tools when authorized.
Start a fresh thread with the assigned model and effort in the build
worktree, and keep the thread ID and caller ID for the exchange. In Codex
desktop environments that expose them, these are `create_thread` and
`send_message_to_thread`. Send the brief and subsequent messages through
the native route.

### Validator with Browser Use or Computer Use

Use a fresh Codex desktop thread with the assigned model and effort.
If Main uses Computer Use to launch the thread, send the complete packet
and wait for the report. The Validator performs the actual checks. If
Main cannot operate the app, prepare the packet and ask the user to
start the thread.

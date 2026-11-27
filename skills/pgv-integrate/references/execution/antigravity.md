# Antigravity execution

Use the assigned model, effort, checkout, and access from
[model routing](../model-routing.md).

## Native build session

The App and CLI use the same native subagent tools. The caller's
Antigravity project must contain the Git checkout at the intended base.
Have the harness allocate the worktree with `Workspace: "branch"`.
[Antigravity projects](https://antigravity.google/docs/projects?tab=cli) ·
[Subagent invocation](https://antigravity.google/docs/subagents#invoking-subagents)

Call `invoke_subagent` with one agent entry:

```json
{
  "TypeName": "self",
  "Role": "<build name>",
  "Workspace": "branch",
  "Model": "inherit",
  "Prompt": "Report your worktree, branch, and base commit via send_message, then wait for the build brief before making changes."
}
```

`Model` selects a tier. With `inherit`, the caller's active model and
effort must match the build assignment. Record the child conversation ID
and verify its model, effort, worktree, and base before sending the brief.

Both sessions use `send_message` for the brief, verdict, decisions, and
reports:

```json
{"Recipient": "<other session's conversation ID>", "Message": "<PGV message>"}
```

An idle child wakes on the next message and retains its context. Keep the
child available through the build and record its branch and commit before
cleanup. [Inter-agent messaging](https://antigravity.google/docs/subagents#inter-agent-communication-and-nesting-limits)

## CLI

### Build session

Use the [native build session](#native-build-session) tools from the
caller. Open the child in `/agents` and inspect its model and effort there.

### Generator and Validator

Authenticate on the execution host with Google Cloud Pay As You Go or
Application Default Credentials (ADC). Check model access with `agy models`.
[Google Cloud sign-in](https://antigravity.google/docs/pay-as-you-go/#antigravity-cli) ·
[ADC](https://antigravity.google/docs/enterprise#setting-up-application-default-credentials-adc)

Use a fresh `agy -p` invocation for each packet. Substitute the manifest's
model and effort in the examples. For Neon, `--model gemini-4-neon --effort <level>` accepts
`low`, `medium`, `high`, and `xhigh`. An effort-specific slug, such as
`gemini-4-neon-xhigh`, pins both values on its own. The examples below
were tested with `agy` 1.5.18 on macOS.
[Antigravity headless reference](https://antigravity.google/docs/cli/headless/#select-a-model-effort-or-agent)

**Generator and Repairer**, in the assigned worktree:

```bash
agy --sandbox --mode accept-edits --model gemini-4-neon --effort medium \
  --output-format json -p "$packet"
```

**Validator**, in the assigned validation checkout:

```bash
agy --sandbox --mode plan --model gemini-4-neon --effort xhigh \
  --settings '{"permissions":{"deny":["write_file(*)"]}}' \
  --output-format json -p "$packet"
```

For a required terminal check, add a scoped `permissions.allow` rule to
the same per-turn `--settings`. Check exit code, JSON `status`, stderr,
and the actual edit or check evidence. A `SUCCESS` can omit a requested
tool result. Save the Validator's complete JSON `response` verbatim at
the report path. Mark checks without valid evidence `UNVERIFIED`.
[Headless permissions and errors](https://antigravity.google/docs/cli/headless/#permissions-in-headless-mode)

## GUI

### Build session

Use the same [native build session](#native-build-session) tools in the
Antigravity App. Open the child through **Overview → Subagents**, then
select **Full View** to see its conversation and input box.
[Subagent messages](https://antigravity.google/docs/at-mentions#message-a-subagent)

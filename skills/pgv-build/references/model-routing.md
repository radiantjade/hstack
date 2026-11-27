# Model routing

This file is the same in `pgv-setup`, `pgv-build` and
`pgv-integrate`. Its source is
`shared/pgv/model-routing.md`; `tools/sync-pgv-shared.sh` copies it.

The skill bodies are model-agnostic. Keep model choices and launch
commands here. Edit the source and run the sync script to update the
copies used by Claude Code and Codex.

## Roles

| Role | What it does |
|---|---|
| Caller | The session the user asked to run `pgv-build`. It agrees the goal and decision policy, starts the build session, handles the review exchange, and relays user decisions and results. |
| Main | Runs the workflow: starts Generator and Validator, decides what the user delegated, assembles, and reports. In `pgv-build` it is the build session. In `pgv-integrate` it is the session the user asked. |
| Planner | Plans how the approved goal is reached and by what checks that is verified. In `pgv-build` it is the build session too: planning is the first step of what that session runs. |
| Plan Reviewer | The caller reviews the plan in the current conversation, using the model and reasoning effort already in use. |
| Generator | Implements the plan. In `pgv-integrate` the same assignment repairs a check that failed. |
| Validator | Verifies the implementation, by the verification that the goal states. |

## Resolve the assignment

Resolve the Build session, Generator, and Validator from the first applicable source in this order.

1. The user's instruction for this run, including ordinary prose in the
   invocation or conversation before launch.
2. The repository's saved `pgv.md` assignment. See `records.md` for its
   location and format.
3. The recommended default below.

Apply a run override only to the roles it names. For unspecified fields,
keep saved choices that fit the override. Infer the backend when only one
supports the chosen model and role. Use the role's recommended compatible
model when only the backend changes and the saved model is incompatible.
For a new model with no explicit effort, use its recommended effort for
the role or the backend's documented default for that model. Record the
resolved value and pass it explicitly. Ask if a needed choice is ambiguous
or the user's explicit combination is unavailable. Apply clear instructions
directly and keep `pgv.md` as the saved assignment for future runs.

For example, “For this build, use Neon at medium for Generator and Neon at
xhigh for Validator” selects two `agy` turns. Resolve the build session
separately.

**Build session.** Main and Planner share a separate session on the
caller's harness. Use a model the harness provides natively. A choice
for Main or Planner names that session. Use the caller's current model
and reasoning effort as the recommendation. A saved model preference
from another harness yields to this native recommendation. If the user
explicitly names a non-native model for this run, ask which native model
they want.

**Plan Reviewer.** Review in the current conversation with its actual
model and reasoning effort. Record those values in the manifest when
they are known. Pin the backend, model, and reasoning effort for the
other roles and keep their access and verification requirements.

## Recommended defaults

Offer these first at setup. Use them for roles with no saved assignment or
run override.

| Role | Model | Reasoning effort | Backend and access |
|---|---|---|---|
| Plan Reviewer | The caller's current model | The caller's current effort | Caller session, with read-only access to product code |
| Build session (Main and Planner) | The caller's current native model | The caller's current effort | Separate session on the caller's harness, with Main's authorized scope |
| Generator | Claude Opus 5.5 (`claude-opus-5-5`) | `medium` | `claude -p`, fresh context; writable scope from packet |
| Validator | GPT-6.2 Astra (`gpt-6.2-astra`) | `xhigh` | `codex exec`, or a new Codex desktop app thread when the round needs computer use or browser use (below); fresh context; read-only product code, may write validation report |

The caller gives the plan review verdict directly to the build session.
See [Plan Reviewer](#plan-reviewer).

**In `pgv-integrate`** the host session is Main, the Validator assignment is
resolved as above, and the agent that repairs a failed check takes the
Generator assignment. There is no caller, no build session and no Plan Reviewer.

## Supported choices

Offer combinations confirmed on the environment where the role will run.
The table lists options alongside the recommended defaults above.

| Role | Model | Suggested effort | Backend |
|---|---|---|---|
| Generator | Gemini 4 Neon (`gemini-4-neon`) | `medium` | `agy` |
| Generator | GPT-6.2 Sol (`gpt-6.2-sol`) | `high` | `codex exec` |
| Validator | Gemini 4 Neon (`gemini-4-neon`) | `xhigh` | `agy` |
| Validator | Claude Opus 5.5 (`claude-opus-5-5`) | `xhigh` | `claude -p` |

Claude Code and Codex models can also fill those roles when the chosen
terminal backend can meet the role's access and check requirements. For
the build session, offer native models from the caller's harness and use
its two-way message route. For required Codex Browser Use or Computer
Use, select a Codex desktop Validator when resolving the run assignment.

## The build session

One interactive session for one build, started with a fresh context on
the caller's harness. It keeps its context for the whole build, the user can open it and
talk to it, and it exchanges messages with the caller. The build session
starts a fresh [CLI turn](#cli-turns) for each Generator or terminal
Validator packet.

Where the host has its own function for starting a session and for messages
between sessions, use that function, not a shell command.

**Claude Code, desktop app.**
- Start it with the app's tool that starts a separate session: a fresh
  context, the build session's model, the caller's own permission mode, a
  worktree of the repository of the work, and a name that names the work.
  Where the caller's own session is in that repository, the tool's option
  for a worktree of its own makes it; where it is not, make the worktree
  with `git worktree add` and give that folder as the session's folder.
- The app starts a session at the caller's effort or lower. When the
  build session's effort is higher than the caller's, do it in this order: start
  the session with a prompt that only tells it to wait for the brief; set
  its effort with the app's tool that sets another session's effort; read
  that session's settings back and confirm that its model and its effort are
  the assigned ones; then send the brief as a message. A change of effort
  holds from the session's next turn, so a brief sent before the change
  would be planned at the lower effort. If the app asks the user to allow
  the change, that answer is the user's. If the model or the effort is not
  the assigned one after this, stop and report.
- Messages go through the host's tool for a message to another session, in
  both directions.

**Claude Code, terminal.**
- Make the build's worktree with
  `git worktree add <path> -b <branch> <the branch the work will enter>`,
  and start the session in that folder:
  `claude --bg --name "$name" --model "$model" --effort "$effort" --permission-mode "$permission_mode" "$brief"`.
  Use the assigned model and effort and the caller's permission mode.
  It prints the session's id: keep it. A long brief goes in a file that the
  prompt names.
- Messages go through the host's tool for a message to another session, in
  both directions.
- A background session that has ended its turn and has no terminal attached
  is stopped after about an hour, and its conversation is kept. A message to
  a stopped session fails as not reachable: run `claude respawn <id>`, then
  send it again.

**How one session names the other.** Answer a message through the sender
that the message itself carries. To begin an exchange, use the other
session's name: the address behind a sender changes each time that session's
process is started again, and the name does not. The caller gives the
build session its name; the brief tells the build session the caller's name.

**The two sessions run in the same permission mode.** A message between
sessions in different modes is held for the user's approval and can expire.

**Codex.** The caller and build session are separate Codex sessions.
For the CLI route, the caller puts its thread ID from `$CODEX_THREAD_ID`
in the brief. Start the build's first turn in its worktree with
`codex exec -m "$model" -c "model_reasoning_effort=\"$effort\"" "$brief"`
and record the returned thread ID. Either session can send a message to
the other with `codex queue --thread "$thread_id" --resume --message "$text"`.
Confirm the first exchange arrived before continuing to plan review.

## Plan Reviewer

The caller reviews the versioned plan as part of its existing
conversation, using the approved agreements, settled user qualifications,
and relevant sources. The caller sends its verdict and evidence to the
build session.

## Validator

Start a fresh Validator with the backend, model, and reasoning effort in
the manifest. For a user-visible end-to-end check on this computer,
Validator performs the actual app or browser interaction with Codex
Browser Use (the `node_repl` browser service) or Codex Computer Use (the
`computer-use` MCP server), as the criterion requires. If a required
capability is unavailable, mark the affected criteria `UNVERIFIED` with
the reason. Validator's read-only access to product code still applies
while operating an app.

**Validator backend for each round.**
- For terminal checks, start a fresh turn using the assigned
  [CLI backend](#cli-turns).
- For a round that needs Codex Computer Use or Browser Use, start a new
  Codex desktop app thread with the assigned Codex model and effort.
  This is the desktop backend in the default Validator assignment.
  The terminal Codex backend has previously failed to find app windows
  (`cgWindowNotFound`, 2026-09-26) and reported no available browser in a
  sandboxed turn (2026-09-27). If a check discovered later requires a
  capability the assigned backend lacks, report it and obtain an explicit
  assignment change before using a different backend.
- Main may start that thread itself by operating the Codex desktop app with
  the host's computer use (for example, computer use in the Claude desktop
  app): open the app, start a new thread, confirm the model and reasoning
  effort, paste the complete validator packet, and send it. Main does nothing
  else in that thread: it does not answer questions on the Validator's
  behalf, steer, or edit it. Main waits for the report file the packet names,
  then reads it. Main's computer use here only starts the turn; it is never a
  check toward any criterion.
- If Main's computer use cannot operate the Codex desktop app (access not
  granted, or the app's access level does not allow typing), prepare the
  packet and ask the user to start the thread.
- Record in the round's validation packet which backend ran it.

## CLI turns

Run from the role's assigned checkout. Pass the entire packet as
`"$packet"` to a fresh invocation with the model and effort from the
manifest.

| Backend | Command |
|---|---|
| `claude -p` | `claude -p --model "$model" --effort "$effort" "$packet"` |
| `codex exec` | `codex exec -m "$model" -c "model_reasoning_effort=\"$effort\"" "$packet"` |

Apply the role's access rules when launching a CLI turn. Validator keeps
read-only access to product code and returns full findings and check evidence.

### Antigravity CLI

Use Google Cloud Pay As You Go or Application Default Credentials (ADC)
for the `agy` backend. Authenticate on the host that runs the role and
check `agy models` before offering Neon. [Google Cloud sign-in](https://antigravity.google/docs/pay-as-you-go/#antigravity-cli) · [ADC](https://antigravity.google/docs/enterprise#setting-up-application-default-credentials-adc)

Pin the base model and reasoning effort with
`--model gemini-4-neon --effort <level>`. Neon supports `low`, `medium`,
`high`, and `xhigh`. An effort-specific model slug from `agy models`, such
as `gemini-4-neon-xhigh`, pins both values by itself. Use one of these
forms per invocation. The examples use the suggested assignments above.
The role commands were tested with `agy` 1.5.18 on macOS.
[Antigravity headless reference](https://antigravity.google/docs/cli/headless/#select-a-model-effort-or-agent)

**Generator and integration Repairer.** Run in the assigned worktree with
the packet's writable scope and focused checks.

```bash
agy --sandbox --mode accept-edits --model gemini-4-neon --effort medium \
  --output-format json -p "$packet"
```

**Validator.** Keep product files read-only. Ask for direct file reads,
the exact check commands from the packet, and the complete report in the
same turn's response. For a required terminal check, add a scoped
`permissions.allow` rule for that command to the same per-turn
`--settings` object.

```bash
agy --sandbox --mode plan --model gemini-4-neon --effort xhigh \
  --settings '{"permissions":{"deny":["write_file(*)"]}}' \
  --output-format json -p "$packet"
```

For each role, check the process exit code, JSON `status`, and stderr.
A `SUCCESS` response can omit a requested tool result, even with empty
stderr. Verify the actual edit or check evidence before accepting the
result. When Validator returns a complete report, Main saves its JSON
`response` verbatim at the packet's report path. Mark denied or missing
checks `UNVERIFIED` when no valid evidence establishes them. [Antigravity headless permissions and errors](https://antigravity.google/docs/cli/headless/#permissions-in-headless-mode)

## Manifest

In `pgv-build`, show the resolved assignments with the Stage 0 contract.
The caller records them in the manifest and includes it in the brief
before launching the build session. Include any role choices the user
gives in the Stage 0 exchange. In `pgv-integrate`, record the
applicable assignments before the first validation round, with `main` as
the host session. The recorded assignments carry through repairs.

```text
caller: <actual backend, model, reasoning effort>
plan reviewer: <caller session, its actual model and reasoning effort, read-only product code>
build session (main and planner): <caller harness, assigned native model, reasoning effort, session name and launcher>
generator: <backend, model, reasoning effort, writable scope>
validator: <assigned CLI or Codex desktop backend, model, reasoning effort, read-only product code, fresh context, browser use / computer use when e2e checks need them>
fallbacks: none
```

## Rules

- **Isolation:** one fresh context per delegated terminal turn, with the model
  and effort pinned. Pass the self-contained packet, not conversation history.
  The build session starts fresh, from its brief, and never shares the
  caller's context. Validator never reuses Generator's session or an earlier
  validation session. A Codex desktop app thread is one turn: start a new
  thread for every validation round; never continue an earlier one.
- **Plan review:** the plan is written in one session and reviewed in
  another. The build session never reviews its own plan.
- **Validation independence:** Validator is a different model family from
  Generator in the default assignment. Whatever the assignment, its
  independence comes from a separate fresh context, read-only product
  access, and raw evidence; where Validator and Generator are of one family,
  do not claim model diversity.
- **Unavailable assignment:** if the selected model, effort, or required
  isolation is unavailable, stop and report; never silently substitute.
- **Repairs:** retain the assigned Generator effort during repair turns and
  the assigned Validator effort during every fresh revalidation turn.

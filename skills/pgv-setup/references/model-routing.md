# Model routing

This file is the same in `pgv-setup`, `pgv-build` and
`pgv-integrate`. Its source is
`shared/pgv/model-routing.md`; `tools/sync-pgv-shared.sh` copies it.

The skill bodies are model-agnostic. **This file is the only place where
concrete models, and the commands that start them, are named.** To change
who does what, edit the source and run the sync script. Claude Code and
Codex load the skills through symlinks to one checkout, so a single edit
applies to both.

## Roles

| Role | What it does |
|---|---|
| Caller | The session the user asked to run `pgv-build`. It agrees the goal and the decision policy with the user, starts the build session, reviews the plan as Plan Reviewer, and passes on what the user must see or decide. It does not run the build, so it stays free for the user. |
| Main | Runs the workflow: starts Generator and Validator, decides what the user delegated, assembles, and reports. In `pgv-build` it is the build session. In `pgv-integrate` it is the session the user asked. |
| Planner | Plans how the approved goal is reached and by what checks that is verified. In `pgv-build` it is the build session too: planning is the first step of what that session runs. |
| Plan Reviewer | Separately verifies the plan that Planner wrote. In `pgv-build` it is the caller. |
| Generator | Implements the plan. In `pgv-integrate` the same assignment repairs a check that failed. |
| Validator | Verifies the implementation, by the verification that the goal states. |

## Default assignment

The assignment in force is the one in the repository's `pgv.md` (the file
that `pgv-setup` writes; `records.md` says where it is found). Read it
before recording the manifest, and follow it unless the user explicitly
overrides a role for this run. The table below is what `pgv-setup` proposes
to the user, and what is in force when there is no `pgv.md` or it does not
list a role. Whatever the assignment, it sets only the model, the effort and the
backend: the rules below hold for any of them. Pin both the model and
reasoning effort of
every delegated role; do not inherit a different host default silently.

| Role | Model | Reasoning effort | Backend and access |
|---|---|---|---|
| Caller and Plan Reviewer | The host session's current model | The host session's current effort | Host session (Claude Code or Codex); read-only product code, may write the goal record and its review |
| Build session (Main and Planner) | Claude Opus 5.5 (`claude-opus-5-5`) | `xhigh` | The build session: a separate interactive session that the caller starts (below); may write the plan; full within authorized scope as Main |
| Generator | Claude Opus 5.5 (`claude-opus-5-5`) | `medium` | `claude -p`, fresh context; writable scope from packet |
| Validator | `gpt-6.2-astra` | `xhigh` | `codex exec`, or a new Codex desktop app thread when the round needs computer use or browser use (below); fresh context; read-only product code, may write validation report |

**The caller keeps the host session as it is.** It runs in the session the
user invoked the skill from, with that session's model and effort. Record the
values actually in use; do not record a model or effort the session is not
running. The plan is reviewed by the caller, whatever its model family: what
it brings to the review is that it knows what the user asked.

**In `pgv-integrate`** the host session is Main, the Validator assignment is
the one above, and the agent that repairs a failed check takes the Generator
assignment. There is no caller, no build session and no Plan Reviewer.

## The build session

One interactive session for one build, started by the caller with a fresh
context. It keeps its context for the whole build, the user can open it and
talk to it, and it exchanges messages with the caller. It is not a one-shot
turn (`claude -p`, `codex exec`): those are for Generator and Validator,
which take one packet and return one artifact, and which the build session
starts.

Where the host has its own function for starting a session and for messages
between sessions, use that function, not a shell command.

**Claude Code, desktop app.**
- Start it with the app's tool that starts a separate session: a fresh
  context, the build session's model, the caller's own permission mode, the folder
  where the work is made, and a name that names the work.
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
- Start it in the folder where the work is made:
  `claude --bg --name <name> --model claude-opus-5-5 --effort xhigh --permission-mode <the caller's> "<prompt>"`.
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

**Codex as the host of the caller.** Codex has no tool that starts another
thread or sends it a message; these commands do it (tried on 2026-11-26 with
`codex-cli 0.172.0` and Claude Code 2.1.316, each command by itself, not as
one build from start to end):
- The caller learns its own thread id from `$CODEX_THREAD_ID` and puts it in
  the brief.
- A build session on a Claude model is started with the terminal command above. It sends a
  message to the caller with
  `codex queue --thread <the caller's id> --resume --message "<text>"`, which
  runs a turn on that thread.
- The caller sends a message to a build session on a Claude model that has ended its turn
  with `claude stop <id>` followed by
  `claude --bg --resume <id> "<text>"`. Without the stop, the second command
  starts a copy of the session and leaves the original unanswered.
- A build session on a Codex model is a thread of its own: its first turn is
  `codex exec -m <model> -c model_reasoning_effort="<effort>" "<prompt>"`,
  which prints the thread's id, and each later message to it is a
  `codex queue` as above.
- If the first exchange does not arrive, stop and report; do not go on
  without the review.

## Validator

**Validator is fixed** to `gpt-6.2-astra` at `xhigh` in a fresh turn,
whichever host runs Main. When a done state or required existing behavior
needs a user-visible end-to-end check on this computer (an app window, a
browser flow, what a user would see or click), Validator actively uses Codex
browser use (the `node_repl` browser service) and Codex computer use (the
`computer-use` MCP server) to perform that check directly, instead of
inferring the result from code or logs. If either is unavailable in that
turn, mark the affected criteria `UNVERIFIED` with the reason; do not
substitute a weaker check silently. Using these tools to operate apps does
not relax Validator's read-only access to product code.

**Validator backend for each round.**
- A round without such a check: a fresh `codex exec` turn.
- A round that needs Codex computer use or browser use: prefer a new thread
  in the Codex desktop app, with the model and reasoning effort set to the
  assignment above. Reason: from `codex exec`, Codex computer use failed to
  find app windows (`cgWindowNotFound`, observed 2026-09-26), and a sandboxed
  `codex exec` turn reported no available browser for browser use (observed
  2026-09-27).
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

## Manifest

The caller records this manifest before Stage 0 of `pgv-build` and puts it
in the brief of the build session. `pgv-integrate` records it before its
first validation round, with `main` as the host session and without the
roles it does not have. Keep it frozen through repairs:

```text
caller and plan-reviewer: <backend, model, reasoning effort, read-only product code>
build session (main and planner): <backend (the build session, how it was started), model, reasoning effort, the session's name>
generator: <backend, model, reasoning effort, writable scope>
validator: <backend (codex exec; Codex desktop app thread for rounds needing computer/browser use), model, reasoning effort, read-only product code, fresh context, browser use / computer use when e2e checks need them>
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
- **CLI turns:**
  - Generator: a fresh `claude -p --model claude-opus-5-5 --effort medium`
    invocation per turn.
  - Every Validator turn without computer/browser-use checks: a fresh
    `codex exec -m gpt-6.2-astra -c model_reasoning_effort="xhigh"`
    invocation.
  - Validator turns that need computer use or browser use: a new Codex
    desktop app thread with `gpt-6.2-astra` at `xhigh` (see "Validator").
- **Unavailable assignment:** if the selected model, effort, or required
  isolation is unavailable, stop and report; never silently substitute.
- **Repairs:** retain the assigned Generator effort during repair turns and
  the assigned Validator effort during every fresh revalidation turn.

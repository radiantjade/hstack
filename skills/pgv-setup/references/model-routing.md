# Model routing

This file is the same in `pgv-setup`, `pgv-build` and
`pgv-integrate`. Its source is
`shared/pgv/model-routing.md`; `tools/sync-pgv-shared.sh` copies it.

The skill bodies are model-agnostic. **This file is the only place where
concrete models are named.** To change who does what, edit the source and run
the sync script. Claude Code and Codex load the skills through symlinks to one
checkout, so a single edit applies to both.

## Roles

| Role | What it does |
|---|---|
| Main | The agent the user talks to. It runs the workflow, starts the other roles, decides what the user delegated, and reports. |
| Planner | Sets the goal and plans by what criteria it will be verified that the goal was reached. |
| Plan Reviewer | Separately verifies the planning that the Planner wrote. |
| Generator | Implements the plan. In `pgv-integrate` the same assignment repairs a check that failed. |
| Validator | Verifies the implementation, by the verification that the goal states. |

## Default assignment

The assignment in force is the one in the repository's configuration issue
(the "Models" section that `pgv-setup` writes; see `records.md`). Read that
section before recording the manifest, and follow it unless the user
explicitly overrides a role for this run. The table below is what `pgv-setup`
proposes to the user, and what a role takes if that section does not list
it. Whatever the assignment, it sets only the model, the effort and the
backend: the rules below hold for any of them. Pin both the model and
reasoning effort of
every delegated role; do not inherit a different host default silently.

| Role | Model | Reasoning effort | Backend and access |
|---|---|---|---|
| Main | The host session's current model | The host session's current effort | Host session (Claude Code or Codex); full within authorized scope |
| Planner | Same as Main | Same as Main | Host session; read-only product code, may write plan |
| Plan Reviewer | Other family from Planner (below) | `xhigh` | Fresh context; read-only product code, may write review |
| Generator | Claude Opus 5.5 (`claude-opus-5-5`) | `medium` | `claude -p`, fresh context; writable scope from packet |
| Validator | `gpt-6.2-astra` | `xhigh` | `codex exec`, or a new Codex desktop app thread when the round needs computer use or browser use (below); fresh context; read-only product code, may write validation report |

**Main and Planner keep the host session as it is.** They run in the session
the user invoked the skill from, with that session's model and effort. Record
the values actually in use; do not record a model or effort the session is
not running.

**In `pgv-integrate`** the host session is Main, the Validator assignment is
the one above, and the agent that repairs a failed check takes the Generator
assignment. There is no Planner and no Plan Reviewer.

**Plan Reviewer is the other family from Planner.**
- Planner is a Claude model → Plan Reviewer is `gpt-6.2-astra`, `xhigh`, via
  `codex exec`.
- Planner is a GPT model → Plan Reviewer is Claude Fable 5.2
  (`claude-fable-5-2`), `xhigh`, via `claude -p`.

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

Record this manifest before Stage 1 of `pgv-build`, or before the first
validation round of `pgv-integrate` (leave out the roles it does not have),
and keep it frozen through repairs:

```text
main: <backend, model, reasoning effort>
planner: <backend, model, reasoning effort>
plan-reviewer: <backend, model, reasoning effort, read-only product code, fresh context>
generator: <backend, model, reasoning effort, writable scope>
validator: <backend (codex exec; Codex desktop app thread for rounds needing computer/browser use), model, reasoning effort, read-only product code, fresh context, browser use / computer use when e2e checks need them>
fallbacks: none
```

## Rules

- **Isolation:** one fresh context per delegated terminal turn, with the model
  and effort pinned. Pass the self-contained packet, not conversation history.
  Reviewer never reuses Planner's session; Validator never reuses Generator's
  session or an earlier validation session. A Codex desktop app thread is one
  turn: start a new thread for every validation round; never continue an
  earlier one.
- **Cross-model review:** Plan Reviewer must use a different model family
  from Planner. This requirement applies only to plan review.
- **Validation independence:** Validator is always a different model family
  from Generator. It shares the GPT family with Main and Planner when the
  host is Codex. Its independence comes from a separate fresh context,
  read-only product access, and raw evidence; do not claim model diversity
  from Main when the host is Codex.
- **CLI turns:**
  - Generator: a fresh `claude -p --model claude-opus-5-5 --effort medium`
    invocation per turn.
  - Claude Plan Reviewer: a fresh `claude -p --model claude-fable-5-2
    --effort xhigh` invocation per turn.
  - GPT Plan Reviewer and every Validator turn without computer/browser-use
    checks: a fresh `codex exec -m gpt-6.2-astra -c
    model_reasoning_effort="xhigh"` invocation.
  - Validator turns that need computer use or browser use: a new Codex
    desktop app thread with `gpt-6.2-astra` at `xhigh` (see "Validator backend
    for each round").
- **Unavailable assignment:** if the selected model, effort, or required
  isolation is unavailable, stop and report; never silently substitute.
- **Repairs:** retain the assigned Generator effort during repair turns and
  the assigned Validator effort during every fresh revalidation turn.

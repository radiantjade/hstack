# Model routing

Keep model choices in `shared/pgv/model-routing.md` and launch details in
`shared/pgv/execution/`. Run `tools/sync-pgv-shared.sh` after editing.

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

**Build session.** Main and Planner share one separate session on the
caller's harness. Offer only models native to that harness, with its
recommendation first. Use that recommendation when a saved preference
belongs to another harness. If the user explicitly requests an
incompatible model, ask them to choose a native model.

**Plan Reviewer.** Review in the caller session with its actual model
and reasoning effort. Record those values when known. Pin the backend,
model, and effort of the other roles.

## Recommended defaults

### Build session (Main and Planner)

Match the caller's harness before presenting choices.

| Caller harness | Recommended native model | Reasoning effort |
|---|---|---|
| Codex | GPT-6.2 Sol (`gpt-6.2-sol`) | `xhigh` |
| Claude Code | Claude Opus 5.5 (`claude-opus-5-5`) | `xhigh` |
| Antigravity CLI (`agy`) | Gemini 4 Neon (`gemini-4-neon`) | `xhigh` |

### Other roles

| Role | Model | Reasoning effort | Backend |
|---|---|---|---|
| Plan Reviewer | Caller's current model | Caller's current effort | Caller session |
| Generator | Claude Opus 5.5 (`claude-opus-5-5`) | `medium` | Claude Code CLI |
| Validator | GPT-6.2 Astra (`gpt-6.2-astra`) | `xhigh` | Codex CLI or Codex desktop for Browser Use and Computer Use |

**In `pgv-integrate`** the host session is Main, the Validator assignment is
resolved as above, and the agent that repairs a failed check takes the
Generator assignment. There is no caller, no build session and no Plan Reviewer.

## Supported choices

Offer combinations confirmed on the environment where the role will run.
The table lists options alongside the recommended defaults above.

| Role | Model | Suggested effort | Backend |
|---|---|---|---|
| Generator | Gemini 4 Neon (`gemini-4-neon`) | `medium` | Antigravity CLI |
| Generator | GPT-6.2 Sol (`gpt-6.2-sol`) | `high` | Codex CLI |
| Validator | Gemini 4 Neon (`gemini-4-neon`) | `xhigh` | Antigravity CLI |
| Validator | Claude Opus 5.5 (`claude-opus-5-5`) | `xhigh` | Claude Code CLI |

Match the selected backend to the role's access and checks. Select a
Codex desktop Validator for required Codex Browser Use or Computer Use.

## The build session

Create one fresh, interactive session in its worktree on the caller's
harness. The user can follow it in that harness's GUI or CLI. Keep it for
the build and use the harness's native messaging in both directions.
Follow the selected [execution guide](#execution-guides) for launch and
messaging.

## Plan Reviewer

The caller reviews the plan in its current conversation and sends the
verdict and evidence to the build session.

## Generator and Validator

Main starts a fresh non-interactive CLI turn for each Generator,
Repairer, or terminal Validator packet. Run from the assigned checkout
with the model, effort, and access recorded in the manifest. Use the
provider's CLI guide even when Main is running in a GUI.

## Validator

Keep product code read-only. Return complete findings and check evidence
in the specified report. Use a fresh Codex desktop thread when a check
requires Codex Browser Use or Computer Use. The Validator performs the
actual interaction and records the backend in the validation packet.
Mark checks without a required capability `UNVERIFIED` with the reason.
Use the [Codex GUI guide](execution/codex.md#gui) for desktop validation and
the provider's [CLI guide](#execution-guides) for terminal validation.

## Execution guides

Read the guide for the assigned provider and surface. If a saved backend
names a command, use its provider's current CLI guide.

| Provider | CLI | GUI |
|---|---|---|
| Claude Code | [CLI](execution/claude-code.md#cli) | [GUI](execution/claude-code.md#gui) |
| Codex | [CLI](execution/codex.md#cli) | [GUI](execution/codex.md#gui) |
| Antigravity | [CLI](execution/antigravity.md#cli) | [GUI](execution/antigravity.md#gui) |

If the documented route fails, use the error, installed version, current
help or tool schema, and vendor docs to find the supported method. Check
for a session or partial result before retrying. Keep the role, model,
effort, isolation, and permissions. Report any requirement the current
harness cannot meet.

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

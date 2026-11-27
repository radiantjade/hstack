---
name: pgv-build
description: >-
  Build one piece of software-engineering work by plan, generate, validate - a
  user-approved goal and decision policy, then a separate build session that
  runs the rest: an implementation-ready plan reviewed by the caller,
  scoped generation, and independent validation of what this work
  itself must prove, with the validation that only means something once the
  work is combined with other work left as deferred checks for pgv-integrate.
  Use only when the user asks to run pgv-build (/pgv-build or $pgv-build), PGV,
  or the Plan-Generate-Validate loop, or when a session was started with the
  build brief of a pgv-build run. Discussing or editing this skill does not
  invoke the workflow.
---

# PGV build

Agree on the goal and decision policy. Plan, review, implement, and verify
one piece of work. Leave deferred checks for `pgv-integrate`.

Roles are **Caller**, **Main**, **Planner**, **Plan Reviewer**,
**Generator**, and **Validator**. The **caller** is the session the user
asked. It agrees the goal, starts the build session, reviews the plan
in the current conversation, and relays notices and decisions. The
**build session** is a separate interactive session on the caller's
session host. The user can follow it there. It acts as Main and
Planner from Stage 1 to Stage 8. Main starts fresh Generator and
Validator turns.

Before assigning roles, read
[references/model-routing.md](references/model-routing.md) and record the
routing manifest. Before delegating, read
[references/review-protocol.md](references/review-protocol.md) for packets
and evidence. Follow the
[execution guide](references/model-routing.md#execution-guides) for the
selected provider and surface.
Before drafting the goal, read [references/records.md](references/records.md)
for where the files of PGV are kept. None of them is committed.

## Which session you are

- **The user asked you to run this skill: you are the caller.** Do "Before
  Stage 0", Stage 0 and "Start the build session". After that your part is
  the plan review exchange in Stage 2 and "The caller during the build".
  Stages 1 and 3 to 8 belong to the build session.
- **You were started with the build brief of a build: you are the build
  session, Main and Planner.** Start at Stage 1. The goal and the decision policy in your
  brief are approved: do not reopen them. Wherever a stage says to ask or
  tell the user, send it to the caller, which is where the user is.

## Before Stage 0 — the models

Resolve the model, reasoning effort, and backend for each role as
[model routing](references/model-routing.md#resolve-the-assignment) says.
Use the user's natural-language choices for this build first, then
`pgv.md` and recommended defaults.
[Where the files are](references/records.md#where-the-files-are) explains
how to find `pgv.md`.

The files of this run are written in the PGV folder. If the user was not
asked yet whether `.pgv/` is excluded from Git, ask the two questions of the
records reference ("Keeping `.pgv/` out of Git") before anything is
written.

## Stage 0 — Goal and decision policy (hard gate)

Draft the contract from the user request and repository. Ask for context
only when it affects the contract. State the outcome, each done state,
how to measure it, and the exact verification method and expected result.

### Validation scope: this run or the entry

Assign each done state and required regression check one place. Validate
what this work's tree can settle in this run. Defer checks that must run
again on the combined result or moved branch, regardless of other builds'
plans. A slow check of this work's own result stays in this run.

Name the deferred target. Use the work's target branch, or a later
branch or `release` when the check needs that environment. Show each
check as running now or when it enters that target. Run checks now when
the user asks or when the work will skip `pgv-integrate`.

### Approval and decision policy

Present the contract and resolved role assignments for goal approval.
For an unset decision policy, ask how to handle choices the goal and plan
leave open. Offer these three choices.

| Policy | Main may decide | Ask the user when |
|---|---|---|
| **Ask about unsettled decisions** | Work whose answer follows from existing agreements | A choice cannot be resolved from those agreements |
| **Delegate internal implementation** | Necessary internal implementation choices that preserve agreed behavior and external interfaces | A choice changes user-visible behavior or an external interface |
| **Delegate through completion** | Necessary details of behavior and implementation, including changes of approach, within the approved goal and authority | Completion requires changing the goal, done states, scope, explicit constraints, or execution permissions |

All choices preserve approved scope, constraints, and execution permissions;
changes to these require user approval. Full delegation grants discretion
within these boundaries. Honor a clear policy already given in the
conversation; otherwise obtain the selection. Silence or goal approval alone
is not a policy choice. Record the policy and user qualifications beside the
contract. Until the goal is explicitly approved and the policy is settled,
refine only these agreements: no implementation planning, delegation, or code.

### Authority and unexpected decisions

The approved goal, constraints, and decision policy govern every stage. The
plan records the current execution method; peer approval does not create
user requirements or permissions. Applicable repository requirements,
existing behavior outside the approved change, and user work remain binding.

An unexpected fact is not necessarily an unsettled decision. If existing
requirements determine the answer, act on them. Generator raises unsettled
choices to Main unless the packet already authorizes that class of choice.
Main applies the selected policy and may consult Planner for technical
judgment or preauthorize bounded choices in role packets.

When user judgment is required, pause dependent work and send the caller a
decision request: the fact, needed decision, options, recommendation, and
consequences. The caller puts it to the user and returns the answer. Continue
independent work when useful. Record delegated decisions in the plan: what
was unexpected, the choice, its authority, rationale, and effect. Version
material changes and update affected packets. Review a changed approach for
affected blockers under Stage 2; preserve unaffected decisions and approved
completion criteria.

## Start the build session (caller)

After goal and policy approval, start the
[build session](references/model-routing.md#the-build-session) with the
[build brief](references/review-protocol.md#build-brief).

Use a Git worktree on a new branch from the work's target. Let the
session host allocate it when it supports worktree isolation. Otherwise create
it before launch. Use the existing checkout only at the user's direction.
Name the actual worktree and branch in the brief.

Share the build session's name or link. Exchange review requests,
decisions, and results through the session host's messaging route.

## The caller during the build

A message from the build session is one of these:

- **A plan to review.** Review it in the caller session under Stage 2 and
  return the verdict.
- **A decision request.** Put it to the user as it came, and return the
  user's answer in their words. Answer it yourself only where the
  conversation with the user already settled it, and say where.
- **A notice or the final report.** Tell the user. A report is the build
  session's claim: name the files that hold its evidence.

Report only what the build session sent: its silence is not a result. If a
message to it cannot be delivered, the routing reference says how the
session is brought back. Do not do Main's work: no change of this work's
code, no Generator or Validator turn. The user may also talk to the build
session directly, and what they decide there holds.

## Stage 1 — Implementation-ready plan (Planner)

Write a versioned plan at `<date>-<slug>.md` in the PGV folder
([references/records.md](references/records.md)). The plan and every other
file of this run are working files outside Git: do not commit them, and do
not write them among the repository's own documents. Embed the approved goal and selected policy verbatim.
Include only what establishes:

- why the selected approach can reach the done states, grounded in relevant
  code and current behavior; for a defect, evidence for the diagnosis;
- the main change points and necessary dependency order;
- how each done state will be verified, plus checks needed for affected
  existing behavior and applicable repository requirements; for a deferred
  item, the same method and expected observation, written so that an agent
  who has never seen this work can carry it out;
- unresolved choices and how the selected policy will handle them.

Investigate migration, compatibility, security, or operational concerns when
the actual change provides a concrete reason. A plan item earns inclusion by
identifying what approved condition or required existing behavior would fail
without it, or what necessary verification it enables. Relevance to the goal
alone does not establish necessity. Choose the simplest approach supported by
evidence; inspect alternatives when a concrete constraint challenges it.

**Stop planning when** the approach has a supported path to the goal, the
main change points and verification are clear, and remaining uncertainty can
be handled during implementation under the decision policy. Resolve known
feasibility or authority blockers before handoff. Defer details that depend
on implementation evidence instead of pre-solving possible future choices.

## Stage 2 — Plan review (caller)

Planner sends the caller the path and version of the plan. The caller
reviews it in the current conversation and returns the verdict. Check what
the plan actually says against the approved goal, user constraints, and
relevant source.
The review covers three questions.

1. What concrete defect would prevent an approved done state from passing?
2. Does the plan violate a user constraint, execution authority, required
   existing behavior, or applicable repository requirement?
3. Does it include work unnecessary for the approved outcome or those duties?

Return `APPROVED` or `REVISE`. Each blocker identifies the affected condition,
concrete failure or unnecessary work, evidence, and the smallest correction.
A verification gap blocks when a required claim lacks a credible check.
Preferences, optional improvements, and speculative future risks neither
block approval nor become implementation duties. Removal is a valid fix.

Main adjudicates findings against evidence and authority. Planner revises
confirmed blockers and bumps the plan version. Re-review checks those fixes
and their effects; it does not restart an improvement search. Approve when
no supported blocker remains. Record rejected findings with a brief reason.
Delegated discretion cannot waive a supported correctness or authority defect.

If the same disagreement repeats without new evidence, Main resolves a
delegated choice or raises it under the selected policy; the caller then
puts both positions to the user. Cap: **5 turns per
side (10 executions total)**, a backstop, not a target. At the cap, stop and
report the unresolved blocker and evidence.

## Stage 3 — Begin generation

Use the approved plan and decision policy for Stage 4.

## Stage 4 — Generate

Give Generator one coherent objective, the complete approved plan, and
bounded decision authority in one terminal-turn packet. Generator owns
implementation and focused checks until handoff; apply Stage 0 to unexpected
decisions. Require changed paths, raw command outcomes, decisions, and
deviations. Parallel Generators require disjoint file ownership and design
boundaries. Evidence, not a self-authored success claim, establishes completion.
Generator's focused checks are the ones that belong to this run. It does not
run a deferred suite "to be safe"; it runs one only when it needs the result
to develop, and such a result is not evidence for the deferred item.

## Stage 5 — Assemble (Main)

Inspect the actual working tree and diff for scope, overwritten user changes,
unintended files, and exposed secrets. Run checks needed for the combined
result and repository requirements. Reuse Generator evidence when still valid
for the assembled tree; rerun when changes or gaps invalidate it. Make small
corrections directly; return meaningful rewrites to Generator.

Draft the deferred file, with one deferred check for each deferred item, in
the format of [references/records.md](references/records.md), from the plan
and from what Generator actually changed. It is finished in Stage 8.

## Stage 6 — Validate (batch)

Start Validator fresh-context and read-only for product code. Supply the
approved agreements, current plan, final diff and relevant files, and raw
check evidence, never Generator's narrative or confidence. Main also supplies
the prior report and repair summary on revalidation. Save Validator's full
findings and evidence beside the plan at `<plan-slug>-validation-r<N>.md`
using the [routing instructions](references/model-routing.md#validator).
These round-context obligations belong to Main and Validator only.

Account for every approved done state, affected required existing behavior,
and applicable repository requirement. Independently inspect final code and
evidence and perform the direct checks needed to establish those claims.
Reuse raw results only after establishing relevance and validity for the
final tree; a new role alone does not require rerunning an entire suite.
Identify reused evidence and checks actually executed. Missing, stale, or
inadequate evidence requires a direct check or `UNVERIFIED`. User- or
repository-required reruns remain required.

For a deferred item, Validator does not run the check. It reads the drafted
deferred check and answers one question: could an agent with no access to
this run carry it out and judge the result? The claim, the method, the
expected observation, what the work changed and what is already known must
all be there. If so the item is `DEFERRED`, and Validator adds what it
observed that bears on it. A draft that cannot be carried out is an in-scope
defect: the work is not handed on until its unfinished validation can be
finished by someone else.

Return all findings in one batch; a failed check does not end other runnable
checks. Mark blocked criteria `UNVERIFIED` with the reason. Revalidation
focuses new execution on repairs and their effects while accounting for every
required criterion with valid evidence. Use the review protocol's report format.

## Stage 7 — Repair loop

Main confirms findings from code or reproduction. Repair done-state failures,
regressions introduced by the change, and violations of applicable requirements.
Unrelated pre-existing issues and optional improvements do not enter repair
packets or block completion. A pre-existing issue that blocks an approved
outcome follows the decision policy. Record rejected findings briefly; batch
all confirmed in-scope defects into one versioned Generator repair packet,
assemble, then revalidate fresh.

If a failure repeats without new evidence, diagnose before another cycle and
apply the decision policy where a choice is required. Cap: **10 generate/validate
cycles**. At the cap, stop and report remaining defects, evidence, and options.

## Stage 8 — Complete with evidence

Complete when every done state and required regression/repository check that
belongs to this run has valid passing evidence, every deferred item is
`DEFERRED` and written into the deferred file, no confirmed in-scope defect
remains, and the final diff respects scope and user work.
Only the user may accept reduced scope after seeing what is unverified.

Write the deferred file beside the plan
([references/records.md](references/records.md)), with Validator's
observations added and the work identified by its branch and commit. A
deferred check is this run's unfinished validation, handed on with everything
needed to finish it: the work must not enter the target it is addressed to
until the check passes there, and `pgv-integrate` is what runs it. Do not
report the deferred items as validated.

Send the caller the outcome, changes, checks, and limitations. Link the
plan and evidence. List deferred checks and their targets, and report
material decisions made under delegation with their reasons and effects.
Keep turn IDs and detailed evidence in the build records.

## Role boundaries and turn discipline

- The caller owns the agreement with the user and reviews the plan before
  implementation.
- Main owns scope, routing, delegated decisions, assembly, communication
  with the caller, and completion claims. Roles receive self-contained,
  versioned packets, not the raw conversation transcript.
- Each delegation ends with a completed artifact or blocker. Do not send
  progress pings or start duplicate owners. Material new information requires
  the turn to return or be cancelled before replacement.
- Validator is always fresh-context and read-only for product code. Role
  labels in one continuous context are not independence. If isolation is
  unavailable, disclose the limitation and do not claim independence.
- Preserve user changes; never overwrite, revert, or reformat unrelated work.

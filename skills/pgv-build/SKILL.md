---
name: pgv-build
description: Build one piece of software-engineering work by plan, generate, validate - a user-approved goal and decision policy, an implementation-ready plan with cross-model review, scoped generation, and independent validation of what this work itself must prove, with the validation that belongs to a later branch filed as deferred checks for pgv-integrate. Use only when the user asks to run pgv-build (/pgv-build or $pgv-build), PGV, or the Plan-Generate-Validate loop. Discussing or editing this skill does not invoke the workflow.
---

# PGV build

Agree on the user's outcome and decision authority, plan enough to begin
implementation, review for blocking defects and unnecessary work, then
implement and independently verify the agreed result.

This skill is one of three. `pgv-setup` records, once for a repository, which
branches exist, which model does which job, and what each branch must
guarantee. `pgv-build` (this skill) builds one piece of
work and validates what that work itself must prove.
`pgv-integrate` collects the validation that build runs left for a branch,
runs it once on the combined result, and brings the result into the branch.

Roles: **Main**, **Planner**, **Plan Reviewer**,
**Generator**, **Validator**. Before assigning roles, read
[references/model-routing.md](references/model-routing.md) and record the
routing manifest. Before delegating, read
[references/review-protocol.md](references/review-protocol.md) for packets
and evidence formats. Concrete model assignments live only in model routing.
Before drafting the goal, read [references/records.md](references/records.md)
for where the repository's branch rules and deferred checks are kept.

## Before Stage 0 — the repository must be set up

Look for the repository's PGV configuration: the open issue labeled
`pgv:config` ([references/records.md](references/records.md)). If there is
none, stop here. PGV has not been set up for this repository, so neither the
branches nor the models of the roles are decided. Tell the user to run
`pgv-setup` first and offer to start it now. Do not draft a goal, and do not
fall back to defaults.

## Stage 0 — Goal and decision policy (hard gate)

Draft the goal contract yourself from the existing conversation and
repository context. The user reacts to a concrete draft; ask for missing
context only when it prevents drafting an accurate goal.

The contract contains four propositions:

1. **Desired outcome** — what the user wants, in one or two sentences.
2. **Done states** — states that together establish the desired outcome.
3. **Quantification** — how each done state is measured.
4. **Verification** — the method for each state and the exact value or
   observation that counts as done.

### Validation scope: this run or a later branch

A run that validates as if its work went to production alone repeats, for
every piece of work, the checks that only mean something once the pieces are
together. So decide, before the contract is shown, where each check belongs.

Read the repository's PGV configuration, the standing checks of the gated
branches above the entry branch, and the deferred checks already open
([references/records.md](references/records.md)). If no branch above the entry
branch is gated, every check belongs to this run.

Give every done state and every required regression check one place:

- **In this run**: what this work itself makes true, and whatever the entry
  branch requires. Evidence from this run's own tree settles it, and a
  failure points at this work.
- **Deferred to `<branch>`**: a claim about the product as a whole once other
  work is combined with this one, such as a full regression suite, a
  comparison against the branch, or a standing check of that branch.

The test is one question: *if this passes on this run's tree, must it be run
again anyway when the work is combined with other work or the branch moves?*
If yes, running it here pays for it twice; defer it. Cost alone is not a
reason to defer: a slow check of what this work itself claims stays in the
run.

A standing check of a higher branch is not copied into the done states. Note
instead what this work makes that check observe differently (a renamed
command, new output, a known change of timing), because the agent that runs
it later has never seen this work.

Show the split in the contract, each done state marked `in this run` or
`deferred to <branch>`, with the standing checks that will cover this work at
integration listed beneath. Deferral is the default. The user may move any
deferred item into this run; it is then validated here and no deferred check
is filed for it. When you explain the split, use plain words in the user's
language ("validated now" and "validated later, when this goes into
staging"), not this skill's terms.

### Approval and decision policy

Use concise, plain language with nothing essential missing. Present the
contract for explicit approval. Alongside it, ask one short question in the
user's language: **When implementation requires a decision that the agreed
goal and plan do not settle, how should we handle it?** Offer three choices:

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

When user judgment is required, pause dependent work and present the fact,
needed decision, options, recommendation, and consequences. Continue
independent work when useful. Record delegated decisions in the plan: what
was unexpected, the choice, its authority, rationale, and effect. Version
material changes and update affected packets. Review a changed approach for
affected blockers under Stage 2; preserve unaffected decisions and approved
completion criteria.

## Stage 1 — Implementation-ready plan (Planner)

Write a versioned plan at `docs/plans/<date>-<slug>.md` unless the repository
uses another location. Embed the approved goal and selected policy verbatim.
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

## Stage 2 — Cross-model review (Plan Reviewer)

Start Reviewer in a fresh context with a different model family from Planner,
using the assignment in routing. Give it the plan, approved agreements, and
relevant source evidence, not the conversation or Planner's private reasoning.
Review three questions:

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
delegated choice or raises it under the selected policy. Cap: **5 turns per
side (10 executions total)**, a backstop, not a target. At the cap, stop and
report the unresolved blocker and evidence.

## Stage 3 — Transition notice

After approval, tell the user the agreed outcome, policy, plan path/version,
routing manifest, and that generation is starting. This is a notice, not
another approval gate. Later questions follow the selected policy.

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

Draft one deferred check for each deferred item, in the format of
[references/records.md](references/records.md), from the plan and from what
Generator actually changed. Do not file them yet.

## Stage 6 — Validate (batch)

Start Validator fresh-context and read-only for product code. Supply the
approved agreements, current plan, final diff and relevant files, and raw
check evidence, never Generator's narrative or confidence. Main also supplies
the prior report and repair summary on revalidation. Validator writes full
findings and evidence beside the plan to `<plan-slug>-validation-r<N>.md`;
that report survives its otherwise stateless turn. These round-context
obligations belong to Main and Validator only.

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
`DEFERRED` and filed, no confirmed in-scope defect remains, and the final
diff respects scope and user work.
Only the user may accept reduced scope after seeing what is unverified.

File each deferred check as an issue
([references/records.md](references/records.md)), with Validator's
observations added and the work identified by its commits. A deferred check
is this run's unfinished validation, handed on with everything needed to
finish it: the work cannot enter the branch it is addressed to until the
check passes there, and `pgv-integrate` is what runs it. If the issues cannot
be filed (GitHub cannot be reached), say so and give the user the
drafts; do not report the deferred items as validated.

Report the outcome against the goal and compact evidence: changed files,
checks and results, plan version, turn IDs, and limitations. List the
deferred checks with their issue numbers and the branch each is addressed to.
Separately list **unexpected decisions made under delegation**, with reasons
and effects; reference the plan for detail rather than repeating routine work.

## Role boundaries and turn discipline

- Main owns scope, routing, delegated decisions, assembly, communication,
  and completion claims. Roles receive self-contained, versioned packets,
  not the raw conversation transcript.
- Each delegation ends with a completed artifact or blocker. Do not send
  progress pings or start duplicate owners. Material new information requires
  the turn to return or be cancelled before replacement.
- Validator is always fresh-context and read-only for product code. Role
  labels in one continuous context are not independence. If isolation is
  unavailable, disclose the limitation and do not claim independence.
- Preserve user changes; never overwrite, revert, or reformat unrelated work.

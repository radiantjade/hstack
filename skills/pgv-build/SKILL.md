---
name: pgv-build
description: Build one piece of software-engineering work by plan, generate, validate - a user-approved goal and decision policy, then a separate build session that runs the rest: an implementation-ready plan, which the session the user is talking to reviews, scoped generation, and independent validation of what this work itself must prove, with the validation that only means something once the work is combined with other work left as deferred checks for pgv-integrate. Use only when the user asks to run pgv-build (/pgv-build or $pgv-build), PGV, or the Plan-Generate-Validate loop, or when a session was started with the build brief of a pgv-build run. Discussing or editing this skill does not invoke the workflow.
---

# PGV build

Agree on the user's outcome and decision authority, plan enough to begin
implementation, review for blocking defects and unnecessary work, then
implement and independently verify the agreed result.

This skill is one of three. `pgv-setup` records which model does which job.
`pgv-build` (this skill) builds one piece of work and validates what that
work itself must prove. `pgv-integrate` takes the works that enter a branch
together, one or several, runs once on the merged result the validation
their builds left, and brings the result into the branch.

Roles: **Caller**, **Main**, **Planner**, **Plan Reviewer**,
**Generator**, **Validator**. Two sessions carry the first four. The
**caller** is the session the user asked: it agrees the goal with the user,
starts the build session, reviews the plan as Plan Reviewer, and passes on
what the user must see or decide. The **build session** is a separate
interactive session that the caller starts: it runs this build from Stage 1
to Stage 8. It is Main, and Planner too, since planning is the first step of
what it runs. The caller therefore does not run
the build, and stays free for the user; several builds can run at the same
time, each in a build session of its own. Generator and Validator are
terminal turns that the build session starts.

Before assigning roles, read
[references/model-routing.md](references/model-routing.md) and record the
routing manifest. Before delegating, read
[references/review-protocol.md](references/review-protocol.md) for packets
and evidence formats. Concrete model assignments, and how a session is
started and reached, live only in model routing.
Before drafting the goal, read [references/records.md](references/records.md)
for where the files of PGV are kept. None of them is committed.

## Which session you are

- **The user asked you to run this skill: you are the caller.** Do "Before
  Stage 0", Stage 0 and "Start the build session". After that your part is
  the plan review of Stage 2 and "The caller during the build". Stages 1 and
  3 to 8 are not yours.
- **You were started with the build brief of a build: you are the build
  session, Main and Planner.** Start at Stage 1. The goal and the decision policy in your
  brief are approved: do not reopen them. Wherever a stage says to ask or
  tell the user, send it to the caller, which is where the user is.

## Before Stage 0 — the models

Read `pgv.md` in the PGV folder;
[references/records.md](references/records.md), "Where the files are", says
how that folder is found. If it exists, its
assignment is in force. If it does not, the defaults of the routing
reference are in force: nothing has to be set up before a build.

The files of this run are written in the PGV folder. If the user was not
asked yet whether `.pgv/` is excluded from Git, ask the two questions of the
records reference ("Keeping `.pgv/` out of Git") before anything is
written.

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

### Validation scope: this run or the entry

A run that validates as if its work went to production alone repeats, for
every piece of work, the checks that only mean something once the pieces are
together. So decide, before the contract is shown, where each check belongs.

Give every done state and every required regression check one place:

- **In this run**: what this work itself makes true. Evidence from this
  run's own tree settles it, and a failure points at this work.
- **Deferred**: a claim about the product as a whole, which other work can
  change: a full regression suite, the use cases walked from start to
  finish, a comparison against the branch. `pgv-integrate` validates it when
  the work enters a branch, once for everything that enters together.

The test is one question: *if this passes on this run's tree, must it be run
again anyway when the work is combined with other work or the branch moves?*
If yes, running it here pays for it twice; defer it. Cost alone is not a
reason to defer: a slow check of what this work itself claims stays in the
run.

The answer does not depend on what other work exists. Do not look for what
other builds deferred, and do not try to find out whether a check overlaps
with theirs: defer what the question says to defer. `pgv-integrate` reads
the deferred checks of everything that enters together and runs what several
of them ask for once. A work that enters alone has the same checks run for
it alone.

A deferred check names the target it is addressed to: the branch this work
will enter, which is the branch it was taken from unless the user says
otherwise. Address a check to a later target (another branch, or `release`)
only when it needs something that exists only there, such as an environment
that is brought up for a release.

Show the split in the contract, each done state marked `in this run` or
`deferred to <target>`. The user may move any deferred item into this run;
it is then validated here and no deferred check is written for it. If the
user says that this work will not go through `pgv-integrate`, everything
belongs to this run. When you explain the split, use plain words in the
user's language ("validated now" and "validated later, when this is merged
into main"), not this skill's terms.

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

When user judgment is required, pause dependent work and send the caller a
decision request: the fact, needed decision, options, recommendation, and
consequences. The caller puts it to the user and returns the answer. Continue
independent work when useful. Record delegated decisions in the plan: what
was unexpected, the choice, its authority, rationale, and effect. Version
material changes and update affected packets. Review a changed approach for
affected blockers under Stage 2; preserve unaffected decisions and approved
completion criteria.

## Start the build session (caller)

When the goal is approved and the policy is settled, start the build
session as the routing reference says: its model and effort, how it is
started on this host, and how the two sessions send each other messages.
Its first input is the build brief of the review protocol: the approved
goal and policy record verbatim, what the conversation settled that the
record does not carry, the repository, the PGV folder and where the work
is made, the routing manifest, and the name under which it reaches you. The
build session starts fresh: it knows nothing of your conversation but the
brief.

**Each build is made in a working tree of its own.** Builds can run at the
same time, and a build can be started while another is still running. Two
builds that write in one working tree overwrite or pick up each other's
changes, and then neither diff is the work of one build. So start the build
session in a Git worktree of the repository, on a branch of this work, taken
from the branch the work will enter unless the user says otherwise. Use the
repository's own checkout only when the user says so. The brief names the
worktree and the branch.

Tell the user that the build session started, its name, and that they can
open it. Then end your turn. You do not plan, delegate or check on it: its
messages reach you.

## The caller during the build

A message from the build session is one of these:

- **A plan to review.** Review it under Stage 2 and answer with the verdict.
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

Planner sends the caller a request for review with the path and the version
of the plan; the plan is the file, not the message. The caller reviews it as
Plan Reviewer. It knows the conversation with the user, which the build
session does not: it checks the plan against what the user asked, reads the
relevant source itself, and judges the plan as it is written, not Planner's
reasoning. Review three questions:

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

## Stage 3 — Transition notice

After approval, Main sends the caller a notice for the user: the agreed
outcome, policy, plan path/version, routing manifest, and that generation is
starting. This is a notice, not another approval gate. Later questions follow the selected policy.

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

Send the caller the final report, which it gives to the user. Report the
outcome against the goal and compact evidence: changed files,
checks and results, plan version, turn IDs, and limitations. List the
deferred checks with the path of the deferred file and the target each is
addressed to, and say that `pgv-integrate` runs them when the work enters.
Separately list **unexpected decisions made under delegation**, with reasons
and effects; reference the plan for detail rather than repeating routine work.

## Role boundaries and turn discipline

- The caller owns the agreement with the user and the plan review. It does
  not run the build.
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

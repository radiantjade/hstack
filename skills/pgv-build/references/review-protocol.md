# Role handoff and validation protocol

Use these formats with the stages in `../SKILL.md`, which define authority,
decision policies, review blockers, verification, and repair eligibility.
Models come from `model-routing.md`.

## Goal and policy record (Stage 0)

```text
Desired outcome: <1-2 sentences>
Done states:
  S1: <state> | measured by: <quantification> | verified by: <method> -> <expected value/observation> | where: in this run
  S2: <state> | measured by: ... | verified by: ... | where: deferred to <target>
  ...
Constraints and scope boundaries: <user and applicable repository instructions>
Goal approval: <user's explicit approval, quoted or referenced, with date>
Decision policy: <selected option or equivalent explicit user instruction>
Policy qualifications: <user-specified limits, if any>
Policy source: <user selection/instruction, quoted or referenced>
```

`where` is `in this run` or `deferred to <target>`, decided under Stage 0's
validation scope. When the user said that the work will not go through
`pgv-integrate`, every state is `in this run`.

Embed this record verbatim in the plan. Separate execution methods from the
approved conditions they serve. For necessary regression or repository checks,
identify the affected behavior or applicable rule. Each check specifies its
method and expected observation; it does not authorize a new requirement.

## Turn envelope

Each delegation receives one versioned packet and returns one terminal
artifact or blocker. Include this envelope once and only applicable fields;
avoid copying full inputs already present in an attached plan.

```text
Turn ID:
Role: planner | plan-reviewer | generator | validator
Turn kind: planning | plan-review | implementation | validation | repair | revalidation
Plan version:
Owned outcome:
Authoritative inputs: <approved agreements and relevant sources>
Writable scope: <explicit paths/components; read-only roles may write their specified report>
Delegated decision authority: <bounded choices permitted by the selected policy>
Stop conditions:
Deadline: <only if supplied by the user or execution environment>
Expected terminal artifact:
```

Silence is not a handoff. Before replacing an active packet, let the turn
return or cancel it.

## Planner packet

```text
Approved goal and policy record: <verbatim>
Relevant repository instructions, current state, source and test paths:
Known constraints and preserved changes:
Required output: implementation-ready plan per Stage 1, written to <path>
```

Apply Stage 1's necessity test and stopping condition. Conditional concerns
do not become mandatory plan sections.

## Plan-review packet

```text
Plan document: <full content or accessible path, including approved agreements>
Relevant code and evidence: <support for approach, constraints, and checks>
Review scope: <initial: Stage 2 questions | re-review: confirmed blockers, changes, and their effects>
Prior findings and disposition: <on re-review only>
Required verdict: APPROVED | REVISE
Blocking findings: <id, location, affected condition, concrete failure/unnecessary work, evidence, smallest correction>
Exchange: <n of maximum 5 per side>
```

Reviewer gets neither the conversation nor Planner's private reasoning.
Main adjudicates findings under Stage 2 and routes necessary revisions.
Record final disposition and approval in the plan. Optional observations
remain separate from Generator obligations.

## Decision request and record

When Stage 0 requires Main or user judgment, return:

```text
Unexpected fact and evidence:
Unsettled choice: <why existing agreements do not determine it>
Options, recommendation, and consequences:
Authority boundary: <why Main/user judgment is required>
Dependent work paused; independent work completed or available:
```

Main records the resolution and updates affected packets per Stage 0.
Generator reports decisions within preauthorized classes at handoff so Main
can record them too.

## Generator packet

```text
Owned objective and files/components:
Plan document: <complete content including approved goal, policy, and decisions>
Focused checks: <plan references; avoid copying criteria already present>
Preserved user changes and do-not-touch scope:
Expected terminal artifact: changed paths, raw check outcomes, decisions, deviations, blockers
```

Generator owns the objective until handoff. Apply the packet's decision
authority and Stage 0. Pause work requiring missing authority or overlapping
another owner's work and return the specific blocker.

## Assembly evidence bundle

Main assembles repository status and final diff, relevant final source, raw
commands with exit status and unedited output, known gaps, and preserved-change
checks. Include end-to-end steps and observations when the criteria need them.
Tie results to the checked code state (revision and relevant working-tree
changes) so later roles can judge validity. Remove secrets and exclude
Generator confidence statements from Validator inputs.

Add the drafted deferred file, with one deferred check for each deferred
item, in the format of `records.md`, written from the plan and from what
Generator actually changed.

## Validator packet

```text
Approved goal and policy record: <in the attached plan>
Round: r<N>
Current plan: <execution methods, decisions, and required-check mapping>
Prior validation report and repair summary: <r1: none | prior report plus changes since it>
Final diff and relevant final files:
Raw check outputs and checked code state:
End-to-end evidence: <when needed>
Drafted deferred checks: <one for each deferred item, or none>
Known limitations:
Validation report output path: <plan-slug>-validation-r<N>.md
Mandate: read-only for product code, fresh context, evidence-based batch result per Stage 6
```

Main provides all round context; Validator writes complete findings to the
report because no session memory survives. These obligations do not belong
in Planner or Generator packets. Independently inspect code and raw evidence
instead of accepting an earlier role's verdict.

Required report:

```text
Done states: S1..Sn: PASS | FAIL | UNVERIFIED | DEFERRED, each with evidence
Deferred checks: <for each DEFERRED state: whether the draft can be carried out by an agent that has not seen this run; what is missing; observations of this round that bear on it>
Required regression/repository checks: <affected behavior/rule, verdict, evidence>
Evidence handling: <direct checks run; reused results and why still valid>
In-scope defects: <severity, location, affected condition/rule, reproduction or code evidence, expected, observed>
Other observations: <only material incidental issues; outside repair/completion criteria>
Unverified claims and blockers:
Overall verdict: PASS | FAIL | BLOCKED
```

`PASS`: all criteria that belong to this run have valid passing evidence,
every deferred item is `DEFERRED` with a draft that can be carried out, and
no in-scope defect remains. `DEFERRED` is given only to an item that the
approved record marks `deferred to <target>`; Validator does not run its
check and does not defer anything else. `FAIL`: a supported in-scope defect exists. `BLOCKED`:
required evidence is unavailable without an established defect. Keep
per-criterion `UNVERIFIED` entries even when another defect makes the overall
verdict `FAIL`. Optional observations do not fail validation.

Severity describes impact within scope: **Critical** destructive loss,
exploitable security failure, or unusable primary path; **High** done-state
failure or major regression; **Medium** bounded violation of required behavior
or an applicable rule; **Low** minor violation of an explicit requirement.
Severity alone does not put an unrelated issue into scope.

## Repair packet

Main adjudicates eligibility under Stage 7 and batches confirmed in-scope
defects. Record rejected findings with a brief reason.

```text
Owned repair outcome:
Current plan and approved agreements:
Confirmed in-scope findings: <all confirmed findings, severity, evidence>
Affected done states, existing behavior, or repository requirements:
Relevant regression commands:
Preserved user changes and do-not-touch scope:
Expected terminal artifact: changes, raw check outcomes, decisions, remaining blockers
```

Follow repair with assembly and fresh revalidation under Stage 7's
repeated-failure rule and maximum of 10 generate/validate cycles.

## Preserve independence

- Keep Planner's and Generator's private reasoning out of review inputs.
- Validator may write its report but never edit the implementation it judges.
  A Generator session cannot serve as Validator.
- Preserve failed commands, skipped paths, and environmental gaps in evidence.
- Uncertainty stays `UNVERIFIED` or `BLOCKED`; it is not a pass.

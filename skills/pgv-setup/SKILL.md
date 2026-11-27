---
name: pgv-setup
description: Save PGV model choices for a repository in .pgv/pgv.md. Use when the user asks to set up PGV or change saved choices. Apply choices for a single build in that build.
---

# PGV setup

## 1. Check

Find the repository and its [PGV folder](references/records.md#where-the-files-are).
Read `pgv.md` if present. Identify the caller's harness, available backends,
and repository model requirements. Use the
[execution guide](references/model-routing.md#execution-guides) to verify
an untested model choice with a one-line prompt before saving it.

## 2. Choose

Use choices already given. Ask one short question for each role that
still needs a choice.

- Which model should run Main and Planner?
- Which model should be the Generator?
- Which model should be the Validator?

List the model and reasoning effort, with the recommendation first.
For Main and Planner, show native models from the caller's harness only.
Use [model routing](references/model-routing.md#recommended-defaults) for
recommendations and [supported choices](references/model-routing.md#supported-choices)
for alternatives. Let the user name another compatible model or effort.
The caller reviews the plan with its current model and effort.

Before writing the first PGV file, follow
[Keeping `.pgv/` out of Git](references/records.md#keeping-pgv-out-of-git)
if the repository still needs that decision.

## 3. Save

Apply the user's Git exclusion choice first. Save the four role rows in
[`pgv.md`](references/records.md#models-pgvmd). Preserve saved choices
for roles the user leaves as they are. Keep the Plan Reviewer row tied
to the caller session. Record any repository-specific instructions
under Notes.

Read the file back. Report the saved roles and path. For a single run,
apply the user's choices as described in
[model routing](references/model-routing.md#resolve-the-assignment).

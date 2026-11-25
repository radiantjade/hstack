---
name: pgv-integrate
description: Bring work into a gated branch of a repository that uses PGV - collect the deferred checks and standing checks of that branch from GitHub issues, validate them once on the commit that will enter, repair what fails, record the gate status, then merge or push. Use when the user asks to merge, push, promote, release or open a pull request into a branch such as staging or main in a repository that uses PGV, when they ask to run the deferred or pending validations, or when GitHub rejects a merge or push because a required pgv/<branch> status is missing. Signs that a repository uses PGV are issues labeled pgv:config, pgv:deferred or pgv:standing, a required status check named pgv/<branch>, or the user saying PGV.
---

# PGV integrate

Build runs put work into the entry branch fast, each one validating only what
it must prove by itself and filing the rest as deferred checks. This skill is
where that unfinished validation is finished: once, on the commit that
actually enters the next branch, with everything that enters together in it.

This skill is one of three: `pgv-setup` records which branches exist, which
model does which job and what each branch must guarantee, `pgv-build`
builds one piece of work, `pgv-integrate` (this skill)
brings what was built into a gated branch.

You are **Main**: the agent the user asked. You start a **Validator** and,
when a check fails, a **Repairer**, each in a fresh context; they never talk
to each other, and what passes between them is the written report. Read
[references/records.md](references/records.md) for where everything is kept
and the exact commands, [references/packets.md](references/packets.md) before
you delegate, and [references/model-routing.md](references/model-routing.md)
for which model runs which role.

## 1. Look

Find out, without changing anything:

- **The configuration** (the issue labeled `pgv:config`). If there is none,
  stop: PGV has not been set up for this repository, so neither the branches
  nor the models of the roles are decided. Tell the user to run `pgv-setup`
  first and offer to start it now. Whether to merge or push in the ordinary
  way without PGV is the user's to say; that is then done outside this skill.
- **Source and target.** The target is the branch the user named. The source
  is what they want to bring in, normally the branch just below the target.
  If the target is not gated, nothing is required: do what the user asked.
- **The commit that will enter.** A gate status belongs to one exact commit,
  and that commit must be the one that becomes the target's tip. So the
  source must already contain the target: if the target has commits that the
  source lacks, they are merged into the source first (step 3), and the
  result is what gets validated. GitHub can only hold a status for a commit
  it has, so the source is pushed before validation.
- **What must pass.** Every open standing check `to:<target>` and every open
  deferred check `to:<target>`. Read their bodies in full.
- **What is already known.** The gate status on that commit, if any. If it is
  already `success`, skip to step 6.

Then put the checks in order. Deferred checks that ask for the same thing
(three build runs each deferring the full regression suite) become one item
to run, with every issue that asked for it listed under it and their notes
on "what an existing check will see differently" gathered together. A
standing check and a deferred check that name the same suite are one run too.

## 2. Say what will happen and ask

Before anything runs, tell the user in their language, briefly:

- what will be validated (the grouped list, with issue numbers), on which
  commit, and where each check runs if the issue says;
- anything that looks out of date, duplicated or impossible to carry out as
  written, with a proposal (edit, close, or run as is);
- what happens if a check fails: you will have it repaired by a fresh agent
  from the report and validate again, unless they prefer to hand the report
  to the session that did the work, or to stop and look.

Use plain words. Standing check, deferred check and gate status are this
skill's own terms and the user has not read this file: say "the tests that
run every time something goes into staging", "the validation that was left
for this moment", "the mark that this commit passed". Show the list as a
table, and keep the question itself to one short sentence.

Then ask whether to proceed. Start nothing before the answer. If the user
has said beforehand that integrations may run without asking, still state
all of the above first, then go on.

A check may be left out only by the user's decision. Record it on the issue
as a waiver (who decided, when, why) and close it if it is a deferred check;
never drop one silently, and never mark as passed what was not run.

## 3. Prepare the commit

If the target has commits the source lacks, merge the target into the source
on the source branch (with the user's agreement from step 2), resolve
conflicts as the repository's rules say, and push the source branch. Note the
head commit: every result of this round is tied to it.

## 4. Validate

Start Validator fresh-context and read-only for product code, with the packet
of [references/packets.md](references/packets.md): the commit, the grouped
checks with the full text of their issues, and the earlier round's report if
there was one. It works in a checkout of exactly that commit, runs each check
as the issue says, and writes one report with a verdict for every item. A
failed check does not end the others. Where a check runs (this machine, a
machine it drives, a hosted runner) is whatever the issue says; the Validator
needs only the issue text, the code and an agent harness.

When it returns, confirm the report covers every item, then record it on
GitHub ([references/records.md](references/records.md)):

- on each issue, a result comment for that issue;
- each deferred check that passed: closed;
- standing checks stay open;
- the gate status on the commit: `success` only when every item passed or was
  waived by the user; otherwise `failure`.

The gate status is what lets the commit in, so it is the one thing you must
not write on trust. Post `success` only from a report that accounts for every
open standing and deferred check of the target at that exact commit.

## 5. Repair, then validate again

When something failed, the Validator has said what failed, with evidence and,
where the evidence points at one, the suspected commit. It does not fix, and
it does not need to know who built what.

Give the report to a Repairer. By default that is a fresh agent in a working
copy of the source branch, with the repair packet of
[references/packets.md](references/packets.md): the failed items, the text of
their issues, the evidence. If the user chose to hand the report to the
session that did the work, give them the report (the result comments on the
issues hold it) and wait for the fix to land on the source branch.

A repair is new commits on the source branch, pushed. That makes a new head
with no status, so go back to step 4 with a fresh Validator. Give it the
earlier report: it runs again what the repair touches and reuses an earlier
result only after establishing that it still holds for the new commit.

Stop and report to the user, with the evidence, when the same failure returns
without new evidence, when a repair would change behavior that a done state
or an issue fixes, or after 5 rounds. A failure that also exists on the
target without this work is not this integration's defect: show it to the
user, who decides whether it blocks.

## 6. Bring it in

With `success` on the head commit, do what the user asked for: fast-forward
the target and push, or open the pull request and merge it. GitHub checks the
status itself; do not look for a way around a refusal. If it refuses, read
why (the status is on another commit, the branch moved, another rule applies)
and return to the step that fixes it.

Report in the user's language: what entered and at which commit, which
deferred checks were closed, which standing checks ran, what was waived, what
was repaired on the way and by which commits, and anything the user should
look at. If something could not be validated, say exactly what and why; do
not round it up.

## What keeps this honest

- One commit, one status. Anything that changes the commit (a repair, a merge
  of the target, a rebase) means the earlier status says nothing about it.
- The Validator is always fresh and never edits the code it judges; the
  Repairer never judges its own repair.
- Only issues and their comments carry context between rounds and between
  machines. Write them so that a reader with nothing else can act. Never
  write session identifiers, local paths, host names or secrets into them:
  they are as visible as the repository.
- Only the user removes a requirement: waiving a check, closing or editing a
  standing check, changing which branches are gated.

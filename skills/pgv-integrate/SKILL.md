---
name: pgv-integrate
description: Bring work that was built with pgv-build into a branch - take the works that enter together (one or several), merge them onto the present tip of the target, collect the deferred checks their builds left, validate them once on that merged commit, repair or take out what fails, then move the target to exactly that commit. Use when the user asks to merge, push, promote, release, or prepare or open a pull request for work built with pgv-build, or to run the deferred or pending validations. Signs that work was built with pgv-build are files named *-deferred.md in PGV's folder (.pgv/ of the repository, or the path in git config pgv.dir), or the user saying PGV.
---

# PGV integrate

A build validates only what its own work must prove, and leaves the rest as
deferred checks: what would have to be run again anyway once the work is
combined with other work. This skill is where that is finished: once, on the
commit that actually enters, with everything that enters together in it.

It runs the same way for one work and for several, and it does not care how
the repository arranges its branches. The user names what enters and where;
the skill makes the commit that would result, validates it, and moves the
target to that commit.

This skill is one of three: `pgv-setup` records which model does which job,
`pgv-build` builds one piece of work, `pgv-integrate` (this skill) brings
what was built into a branch.

You are **Main**: the agent the user asked. You start a **Validator** and,
when a check fails, a **Repairer**, each in a fresh context; they never talk
to each other, and what passes between them is the written report. Read
[references/records.md](references/records.md) for the files and the
commands (the files are in the PGV folder, outside Git: commit none of
them), [references/packets.md](references/packets.md) before you
delegate, and [references/model-routing.md](references/model-routing.md) for
which model runs which role.

## 1. Look

Find out, without changing anything:

- **The models.** Resolve Validator and any Repairer as
  [model routing](references/model-routing.md#resolve-the-assignment) says.
  Apply the user's choices for this entry, then the saved `pgv.md`
  assignments and recommended defaults.
- **The target and what enters.** The target is the branch the user named,
  or `release` when a commit is about to be released. What enters is one
  work or several: the branches the user named (a pull request is its
  branch). If the user did not say which, propose the works that have open
  deferred checks addressed to this target, and ask.
- **Whether an entry into this target is already running.** An entry record
  of this target with `Status: in progress` means one is, here or in another
  session, or that one was abandoned. Do not start a second: tell the user,
  who says whether to wait, to take that one over, or to close it.
- **What must pass.** The open deferred checks addressed to this target, in
  the deferred files of the works that enter (the records reference says how
  they are found). Read them in full. A work with no deferred file left
  nothing, or was not built with `pgv-build`: say which, so that the user
  decides whether it enters as it is.

Then put the checks in order. Deferred checks that ask for the same thing
(three builds each deferring the full regression suite) become one item to
run, with every check that asked for it listed under it and their notes on
"what an existing check will see differently" gathered together. This is the
only place where overlap between works is found: a build does not need to
know what another build deferred.

## 2. Say what will happen and ask

Before making the candidate, show the work, target commit, grouped checks and
their environments, and any missing, stale, or blocked checks. Propose a
resolution where a check cannot run as written.

Ask only for undecided choices. For check failures, offer repair and
revalidate, remove the work and continue, or stop. Resolve whether to open
a pull request or push. Wait for any required answer, then proceed with
the agreed entry.

A check may be left out only by the user's decision. Record it as a waiver
(who decided, when, why); never drop one silently, and never mark as passed
what was not run.

When the user has answered, write the entry record with
`Status: in progress`. That line is what tells another session that this
target is taken.

## 3. Make the candidate

Work in a working copy of your own, not in a checkout someone is working in.

- Make a branch `pgv-entry-<target>` at the present tip of the target and
  merge each work that enters into it. The commit it ends on is the
  **candidate**: what the target will be if everything passes.
- One work that already contains the tip of the target needs no merge: its
  head is the candidate.
- For `release` nothing is merged: the candidate is the commit that is about
  to be released.

A merge conflict belongs to the work that enters later, since what is in the
target was validated when it entered. By the user's choice in step 2 the
work is taken out and goes back to its session, which takes the target into
its branch and resolves it there, or the conflict is resolved here as the
repository's rules say.

Note the candidate's commit: every result of this round is tied to it.

## 4. Validate

Start Validator fresh-context and read-only for product code, with the packet
of [references/packets.md](references/packets.md): the candidate, the grouped
items with the full text of their deferred checks, and the earlier round's
report if there was one. It works in a checkout of exactly that commit and
runs each item as the deferred checks say. Save its report with a verdict
for every item using the
[routing instructions](references/model-routing.md#validator). A failed
check does not end the others. Where a check runs (this machine, a machine
it drives, a hosted runner) is whatever the deferred check says.

When it returns, confirm the report covers every item, then write the
results into the entry record: the candidate's commit with its verdict, and
each item with its result.

The pass of a candidate is what lets it in, so it is the one thing you must
not write on trust. Write it only from a report that accounts for every item
at that exact commit.

## 5. When something fails

The Validator has said what failed, with evidence and, where the evidence
points at one, the suspected commit or work. It does not fix.

By the user's choice in step 2:

- **Repair.** Give the report to a Repairer: a fresh agent in the working
  copy of the candidate, with the repair packet of
  [references/packets.md](references/packets.md). A repair is new commits on
  the candidate branch.
- **Take the work out.** Make the candidate again without that work, and
  give the work's session the failed items and their evidence. Record it
  under "Taken out". The work comes back in a later entry, after its session
  has taken the then present target into its branch and repaired it.

Either way there is a new candidate commit with no result, so go back to
step 4 with a fresh Validator. Give it the earlier report: it runs again
what the change touches and reuses an earlier result only after establishing
that it still holds for the new commit.

Stop and report to the user, with the evidence, when the same failure returns
without new evidence, when a repair would change behavior that a done state
or a deferred check fixes, or after 5 rounds. A failure that also exists on
the target without these works is not this entry's defect: show it to the
user, who decides whether it blocks.

## 6. Bring it in

With a pass on the candidate:

- **Check that the target has not moved** since the entry started. If it
  has, something entered outside this skill: merge the new tip into the
  candidate, which makes a new commit, and return to step 4.
- **Move the target to the candidate by fast-forward only**
  (`git merge --ff-only`). Never bring the candidate in by a merge that
  makes a new commit: that commit was not validated.
- **If the user wanted a pull request**: push the candidate branch and open
  the pull request against the target before the target is moved. When the
  moved target is pushed, the host shows the pull request as merged by
  itself. Do not use the host's merge button; it makes a new commit.
- **Push** the target only if the user asked.
- **For `release`**: put the tag on the candidate.

Then finish the records: in each deferred file, the status of every check
that passed or was waived; in the entry record, `entered at <commit>` and
what was repaired or taken out on the way. Delete the candidate branch.

Report the target commit, what entered, and the check results. Include
waivers, repair commits, and the reasons for removals or unverified
items when applicable.

## What keeps this honest

- One commit, one result. Anything that changes the commit (a repair, a
  merge of the target, a rebase) means the earlier result says nothing about
  it. The target becomes the commit that passed, not one like it.
- The Validator is always fresh and never edits the code it judges; the
  Repairer never judges its own repair.
- Only the files carry context between rounds, sessions and machines. Write
  them so that a reader with nothing else can act.
- Only the user removes a requirement: waiving a check, letting in a work
  that has none, closing an entry that another session left in progress.

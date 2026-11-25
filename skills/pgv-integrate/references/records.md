# PGV records

This file is the same in `pgv-setup`, `pgv-build` and
`pgv-integrate`. Its
source is `shared/pgv/records.md`; `tools/sync-pgv-shared.sh` copies it.

The three skills keep what they need to remember as files beside the plans.
They need Git and nothing else: no host such as GitHub, no issue, label,
commit status or branch rule. A pull request, where one is used, is opened by
the user's usual way for work that was already validated; it is not a record
of these skills.

## Where the files are

**The plans folder** is where this repository's plans are kept: `docs/plans/`
unless the repository's own instructions name another place. It may be inside
the repository or outside it (some projects keep their plans in a separate
folder for several repositories).

| Record | File | Written by |
|---|---|---|
| Models | `pgv.md` in the plans folder. Optional: without it the defaults of `model-routing.md` are in force. | `pgv-setup` |
| Deferred checks | `<plan-slug>-deferred.md` beside the plan of the work. One file for one build, with all the checks that build left. | `pgv-build` |
| Entry record | `<date>-entry-<target>.md` in the plans folder. One for each entry of work into a target. | `pgv-integrate` |
| Validation reports | `<plan-slug>-validation-r<N>.md` beside the plan; `<entry-slug>-validation-r<N>.md` beside the entry record. | Validator |

Commit these files the way the repository commits its plans. They are plan
documents: a change of one of them (a status line, a result) does not change
the product, so it does not make a validated commit unvalidated.

Where the plans folder is inside a repository that others can read, write
nothing private into these files: no session or thread identifier, no local
path, host name, key or address.

## What the records mean

- **Work.** What one `pgv-build` run made: a branch, at a commit.
- **Target.** What work enters through `pgv-integrate`: a branch, or
  `release` (a tag that is about to be put on a commit). The skills do not
  fix which branches a repository has or in what order work moves through
  them. The target of an entry is what the user names.
- **Deferred check.** Validation that a build did not run, because it would
  have to be run again anyway once the work is combined with other work. It
  names the target it is addressed to: the work must not enter that target
  before the check has passed there.
- **An entry.** One or several works that enter a target together. They are
  merged onto the present tip of the target; that merged commit is the
  **candidate**; the deferred checks of those works are validated once on
  the candidate; the target is then moved to exactly that commit.
- **Which deferred checks an entry runs.** Those with `Status: open` and
  `To:` this target, in the deferred files of the works that enter: the
  files whose `Work` line names a branch the user gave, or a commit that the
  candidate contains and the target does not
  (`git merge-base --is-ancestor <commit> <ref>`). The second part finds
  work that came in through another branch.
- **One commit, one result.** A result holds for the exact commit it was
  observed on. Anything that makes a new commit of product code (a repair, a
  merge, a rebase) has no result yet.
- **One entry into a target at a time.** An entry record with
  `Status: in progress` says that an entry into that target is running. A
  second one is not started while it is there.

## Models: `pgv.md`

```markdown
# PGV models

Which model runs which role here.

| Role | Model | Effort | Backend |
|---|---|---|---|
| Planner | <model> | <effort> | <how it is started> |
| Plan Reviewer | <model> | <effort> | <how it is started> |
| Generator | <model> | <effort> | <how it is started> |
| Validator | <model> | <effort> | <how it is started> |

## Notes

<what the user said about how PGV should run here: where tests run, who must
approve an entry into which branch, anything else>
```

`pgv-setup` writes all four roles, with the default where the user kept it,
so that the file says what runs.

## Deferred checks: `<plan-slug>-deferred.md`

```markdown
# Deferred checks: <the work, in a few words>

Plan: <file name of the plan>
Work: branch `<name>` at `<commit>`, taken from `<branch>` at `<commit>`
Areas changed: <components, commands, formats>
What an existing check will see differently: <renamed commands, new output,
changed timings, anything an existing check would otherwise report as a failure>

## D1: <what must be shown>

To: `<branch>` | `release`
Status: open

Claim: <what must be true; the done state or the regression check that was
deferred>

How to check: <method and the exact value or observation that counts as a
pass; the environment it needs. Complete enough for an agent that has never
seen the work.>

Already established: <what the build's own validation observed; known
failures that exist without this work; baselines measured>

## D2: ...
```

`Status` is one of:

- `open`
- `passed at <commit> for <target> (<entry record>)`
- `waived by the user on <date>: <why>`

Only `pgv-integrate` changes a status, and only after the entry.

## Entry record: `<date>-entry-<target>.md`

```markdown
# Entry into `<target>`, <date>

Status: in progress | entered at <commit> | stopped: <why>
Target: `<target>` at `<commit>` when the entry started
Works: <for each: branch at commit; its deferred file>
Candidate: <r1: commit, FAIL> <r2: commit, PASS> ...

## Items

| Item | Asked by | Result |
|---|---|---|
| I1: <what was run, once> | <deferred file> D1, <deferred file> D3 | PASS at <commit> |

## Taken out

<a work that left this entry: which, why, the report that shows it>

## Waived

<a check the user left out: which, when, why>

## Repairs

<commits made on the way, and what each repaired>
```

## Commands

```bash
# Deferred files that still have an open check
grep -l '^Status: open' <plans folder>/*-deferred.md

# Is the work of a deferred file in the candidate and not yet in the target?
git merge-base --is-ancestor <work commit> <candidate> && ! git merge-base --is-ancestor <work commit> <target>

# An entry into this target that is still running
grep -l '^Status: in progress' <plans folder>/*-entry-<target>.md

# The candidate: the works merged onto the present tip of the target
git switch -c pgv-entry-<target> <target>
git merge --no-ff <work branch>        # once for each work that enters

# Move the target to the validated candidate, and nothing else
git switch <target> && git merge --ff-only pgv-entry-<target>
```

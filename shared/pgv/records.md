# PGV records

This file is the same in `pgv-setup`, `pgv-build` and
`pgv-integrate`. Its
source is `shared/pgv/records.md`; `tools/sync-pgv-shared.sh` copies it.

The three skills keep what they need to remember as files in one folder, the
**PGV folder**. PGV commits none of these files. They are the working files of
the person who runs PGV; what the repository keeps of a piece of work is its
commits. The skills need Git and nothing else: no host such as GitHub, no
issue, label, commit status or branch rule. A pull request, where one is
used, is opened by the user's usual way for work that was already validated;
it is not a record of these skills.

## Where the files are

**The PGV folder** is `.pgv/` at the top of the repository's main working
tree (the first line of `git worktree list`). Every worktree and every
session of the repository reads and writes that one folder, not a `.pgv/` of
its own worktree. The user is not asked where the files go.

A repository can name another folder with
`git config --local pgv.dir <absolute path>`, which Git does not commit or
push. Set it only when the user asks for another place; where it is set, that
folder is the PGV folder, and if no folder is at that path, stop and tell
the user.

### Keeping `.pgv/` out of Git

PGV never stages or commits a file of the PGV folder. Whether Git is also
told to leave `.pgv/` out is the user's choice. It is asked once for a
repository, before the first file is written there: when
`git config --get pgv.exclude` gives nothing and Git does not ignore the
folder yet (`git check-ignore -q .pgv/x` in the main working tree). The
skill that is about to write asks: `pgv-setup`, or the caller of `pgv-build`
before Stage 0.

They are two questions, asked one after the other, each by itself, in the
user's language; never one question with all the answers in it.

**First question.**

- "Exclude `.pgv/` from Git? PGV keeps its plans and reports in that folder."
- **Yes**
- **No**: Git shows the folder as untracked; PGV still commits nothing of it.

**Second question, only after a yes.**

- "How should `.pgv/` be excluded?"
- **Add it to `.gitignore`**: the line `/.pgv/` in the `.gitignore` at the
  top of the main working tree. It is a change of a file of the repository,
  so everyone who uses the repository gets it once it is committed. Leave
  that commit to the way the repository takes commits.
- **Exclude it in this clone only**: the same line in
  `$(git rev-parse --git-common-dir)/info/exclude`. Git never commits that
  file, so no file of the repository changes and other clones are not told.

Do not choose for the user, and do not write a PGV file before the answer.
Record the answer so that it is not asked again:
`git config --local pgv.exclude <gitignore | clone | no>`. Nothing is asked
where `pgv.dir` names a folder outside the repository.

A turn that works in another folder (the worktree of a build, the checkout
of a candidate) is given access to the PGV folder, to read the plan and to
write its report.

| Record | File in the PGV folder | Written by |
|---|---|---|
| Models | `pgv.md`. Optional: without it the defaults of `model-routing.md` are in force. | `pgv-setup` |
| Plan | `<date>-<slug>.md`. One for one build, versioned inside the file. | `pgv-build` |
| Deferred checks | `<plan-slug>-deferred.md`. One file for one build, with all the checks that build left. | `pgv-build` |
| Entry record | `<date>-entry-<target>.md`. One for each entry of work into a target. | `pgv-integrate` |
| Validation reports | `<plan-slug>-validation-r<N>.md` for a build; `<entry-slug>-validation-r<N>.md` for an entry. | Validator |

"Beside the plan" in the skills means in the PGV folder, under the plan's
slug.

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
| Build session (Main and Planner) | <model> | <effort> | <how it is started> |
| Plan Reviewer | The session that calls `pgv-build` | That session's effort | That session |
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
# The PGV folder, where the user asked for another place (nothing: .pgv/ of the main working tree)
git config --get pgv.dir

# How the user chose to keep .pgv/ out of Git (nothing: not asked yet)
git config --get pgv.exclude

# The main working tree, and whether Git ignores the PGV folder there
git worktree list | head -1
git check-ignore -q .pgv/pgv.md && echo ignored

# Deferred files that still have an open check
grep -l '^Status: open' <PGV folder>/*-deferred.md

# Is the work of a deferred file in the candidate and not yet in the target?
git merge-base --is-ancestor <work commit> <candidate> && ! git merge-base --is-ancestor <work commit> <target>

# An entry into this target that is still running
grep -l '^Status: in progress' <PGV folder>/*-entry-<target>.md

# The candidate: the works merged onto the present tip of the target
git switch -c pgv-entry-<target> <target>
git merge --no-ff <work branch>        # once for each work that enters

# Move the target to the validated candidate, and nothing else
git switch <target> && git merge --ff-only pgv-entry-<target>
```

# PGV records on GitHub

This file is the same in `pgv-setup`, `pgv-build` and
`pgv-integrate`. Its
source is `shared/pgv/records.md`; `tools/sync-pgv-shared.sh` copies it.

The three skills keep everything they need to remember on GitHub, as issues,
labels, commit statuses and rulesets. Nothing goes into the repository's files
or history: the product branches hold product code only, a check that has
passed leaves no file to delete, and everyone who can open the repository sees
the same records from any machine.

Use the `gh` CLI. In `gh api` paths, write `{owner}` and `{repo}` literally:
`gh` fills them in from the current repository.

## What exists

| Record | What it is | How to find it |
|---|---|---|
| Configuration | One open issue. Its body lists the branches in order and says which are gated. | label `pgv:config` |
| Deferred check | An issue. Validation that a build run left for a later branch. It is closed when it passes. | labels `pgv:deferred` and `to:<branch>` |
| Gate status | A commit status on one commit. | context `pgv/<branch>` |
| Ruleset | A GitHub ruleset on a gated branch that requires the gate status. | name `pgv: <branch>` |

## What the records mean

- **Branch order.** The configuration lists branches lowest first, for example
  `dev`, `staging`, `main`. Work enters the first branch (the entry branch) and
  is integrated upward one branch at a time.
- **Gated branch.** A branch that accepts a commit only when that commit
  carries the gate status `pgv/<branch>` with state `success`. The ruleset makes
  GitHub enforce it for merges and pushes.
- **Gate status `success` on commit C for branch B** means: at C, every
  deferred check `to:B` that was open either passed and was closed, or was
  waived by the user. The status belongs to that exact commit. A new commit
  has no status and must be validated.
- **`to:<branch>`** on an issue means: this must pass before a change enters
  `<branch>`. A deferred check is addressed to the nearest gated branch above
  the entry branch unless it needs something only a higher branch has.
- **No configuration issue** means the repository is not set up: neither the
  branches nor the models of the roles are decided. `pgv-build` and
  `pgv-integrate` do not run; they tell the user to run `pgv-setup` first.

## Configuration issue

Title: `PGV configuration`. Label: `pgv:config`. Exactly one is open.

```markdown
## Branches

Lowest first. Work enters the first branch.

| Branch | Gated | Gate status |
|---|---|---|
| dev | no | - |
| staging | yes | pgv/staging |
| main | yes | pgv/main |

## Models

Which model runs which role in this repository.

| Role | Model | Effort | Backend |
|---|---|---|---|
| Planner | <model> | <effort> | <how it is started> |
| Plan Reviewer | <model> | <effort> | <how it is started> |
| Generator | <model> | <effort> | <how it is started> |
| Validator | <model> | <effort> | <how it is started> |

## Notes

<what the user said about how integration should run: where tests run, who
must approve an integration into which branch, anything else>
```

`pgv-setup` always writes all four roles, with the default where the user
kept it, so that this issue says what runs in this repository.

## Deferred check issue

Title: `Deferred check: <what must be shown>`. Labels: `pgv:deferred`,
`to:<branch>`.

```markdown
## Claim

<what must be true; the done state or the regression check that was deferred>

## How to check

<method and the exact value or observation that counts as a pass; the
environment it needs. Complete enough for an agent that has never seen the
work.>

## The work

Commits: <first>..<last> on <branch> (or: branch <name> at <commit>)
Areas changed: <components, commands, formats>
What an existing check will see differently: <renamed commands, new output,
changed timings, anything an existing check would otherwise report as a failure>

## Already established

<what the build run's own validation observed; known failures that exist
without this work; baselines measured>
```

Identify the work by commits. Do not write session or thread identifiers,
local paths, host names, keys or anything else private: an issue is visible to
everyone who can see the repository.

## Result comment

Written on an issue after a validation round.

```markdown
**<PASS | FAIL | UNVERIFIED>** at <commit> for `<branch>`

Checked: <what was run or inspected>
Observed: <the value or observation; for FAIL, expected and observed>
Evidence: <the lines of output that show it>
Suspected cause: <for FAIL only: commit or area, if the evidence points at one>
```

## Commands

```bash
# Configuration (expect exactly one)
gh issue list --label pgv:config --state open --json number,title,body

# Deferred checks for a branch
gh issue list --label pgv:deferred --label "to:staging" --state open --json number,title,body --limit 200

# File a deferred check
gh issue create --title "Deferred check: ..." --label pgv:deferred --label "to:staging" --body-file <file>

# Record a result, close a deferred check that passed
gh issue comment <number> --body-file <file>
gh issue close <number> --comment "Passed at <commit> for staging."

# Gate status: read, write
gh api "repos/{owner}/{repo}/commits/<commit>/status" --jq '.statuses[] | select(.context=="pgv/staging") | .state'
gh api "repos/{owner}/{repo}/statuses/<commit>" -f state=success -f context=pgv/staging -f description="<n> deferred checks passed"

# What GitHub enforces on a branch
gh api "repos/{owner}/{repo}/rules/branches/staging"
```

A commit status can be written only for a commit that GitHub has, so push the
branch first. `state` is one of `success`, `failure`, `pending`, `error`.

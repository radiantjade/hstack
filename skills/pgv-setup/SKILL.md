---
name: pgv-setup
description: Set up or change PGV for a GitHub repository - find the branches and their order, settle which model does which job and whether GitHub locks the branches, then create the labels, the configuration issue and the rulesets that pgv-build and pgv-integrate rely on. Use when the user asks to set up or configure PGV, to change its branches or models, or when pgv-build or pgv-integrate found no PGV configuration and the user wants one.
---

# PGV setup

While features are built with PGV, validation that overlaps between them is
not repeated for each one: a build validates what its own work must prove
and leaves the rest, and what was left is validated once, when the work is
merged into a branch. This skill records, on GitHub, which branches a
repository has and in what order work moves through them, and which model
does which job.

This skill is one of three: `pgv-setup` (this skill), `pgv-build`, which
builds one piece of work, and `pgv-integrate`, which brings what was built
into a branch.

Nothing is written into the repository's files. Everything is an issue, a
label or a ruleset; [references/records.md](references/records.md) has the
formats and the commands.

Repositories differ, and so does how people want to run their branches. So
look first, propose what you found, and let the user correct it; do not make
them describe their repository from nothing.

## 1. Look

- Access: `gh auth status`, then
  `gh repo view --json nameWithOwner,visibility,defaultBranchRef,viewerPermission,hasIssuesEnabled`.
  Filing issues and writing statuses needs write access; creating a ruleset
  needs admin access. If issues are disabled, PGV has nowhere to keep its
  records: say so and stop.
- **Whether GitHub can enforce a gate in this repository.** Read the rulesets
  with `gh api "repos/{owner}/{repo}/rulesets"`. An HTTP 403 that speaks of
  the plan or of upgrading means rulesets cannot be used here (a private
  repository on a plan without them); missing admin access means the user
  cannot create one. Find this out now, so that the question about the
  GitHub lock in step 2 is asked with the facts in hand and it never turns
  up as a surprise error while things are being created.
- Branches: the remote branches, the default branch, which ones look
  long-lived (`main`, `staging`, `dev`, `develop`, `release`, ...) and which
  are short-lived work branches.
- What already protects the long-lived branches (the rules of each).
- Which agents this machine can run: whether the `claude` and `codex`
  commands exist, and the model of the session you are in. A role can only
  be given to a model the user can actually start.
- Whether PGV is already set up: an open issue labeled `pgv:config`. If so,
  this run changes an existing setup: read it and ask what should change.

## 2. Ask

Ask only what the user has to decide. What you can find out yourself (which
branches exist, which is the default, what tests the repository has, whether
GitHub can lock a branch) you find out in step 1 and state as a fact; you do
not ask it back. A question whose answer you already hold tells the user
that you did not look.

The decisions, one at a time and in this order: which repository (only when
that is not obvious), which models, the GitHub lock.

### How every question is built

Assume the user knows nothing about PGV. Build each question the same way:

1. **The question first**, one sentence, about their repository and in
   their words.
2. **Then one sentence on why you ask**: what PGV does with the answer.

Never open with an explanation and trail off into a question, and never ask
about PGV's own settings. Compare:

| Not this | But this |
|---|---|
| "Which branches does this repository have?" | Nothing: you looked. State it: "This repository has one branch, main." |
| "May I create a ruleset?" | "Shall GitHub refuse a push into main that skipped validation?" |

Further rules:

- This skill's own words (deferred check, gate status, gated branch,
  configuration issue, ruleset) never appear. Say "validation
  before a merge into main", "GitHub lock".
- Short and concrete: who does what and when, not abstractions. Each choice
  is explained in under a dozen words.
- Where a question has choices, offer what you found in the repository
  first, so that the user confirms instead of describing.
- A choice says what it contains. Do not coin a label for a group of things
  ("the core ones", "the basics", "the standard set") and then ask about
  the label: the user cannot know what you put behind it. Name the items in
  the choice, or say how many and which, and what choosing it costs.
- If the question is shown in a dialog, the user may see nothing but the
  dialog, and a dialog shows only a question and its choices well. Do not
  put a table or a preview block in it: split what would have been a table
  into one question for each row, with the alternatives as the choices.
- Do not tell the user about your own procedure (drafts, issue bodies,
  labels).

### The questions

1. **Which repository**, only when it is not obvious. If the folder you are
   in holds several repositories, or the user did not say which one they
   mean, this comes before everything else: "Which repository shall PGV be
   set up for?", with each candidate and a few words on what it is. Look at
   the chosen one (step 1) before going on.
2. **The branches are stated, not asked.** Say what you found and what
   follows from it, as the opening of the next question: "This repository
   has one branch, `main`." With several long-lived branches, state the
   order you read from them (`dev`, then `staging`, then `main`); ask only
   if the order really cannot be told, and then ask to confirm your reading.
   From this you derive what the records call the entry branch (the lowest,
   where build runs deliver) and the gated branches (each one above it). If
   the repository is public, add that everything PGV records is readable by
   anyone.
3. **Models**, one question for each job that is a choice. Do not ask "keep
   these?" over a table of roles: the user has to decode the table before
   they can answer. Ask about one job at a time, in plain words, with the
   models themselves as the choices:

   - Planning is done by the model the user is talking to. That is not a
     choice; state it as the opening of the next question.
   - "Planning is done by the model you are talking to. Which model should
     check that plan separately?"
   - "Which model should build what the plan says? It also repairs what
     validation finds."
   - "Which model should validate what was built? It checks the result the
     way the goal says."

   Each choice is a model with its effort (for example "Opus 5.5, xhigh"),
   the recommended one first, with a few words on why: the default of
   [references/model-routing.md](references/model-routing.md), or the same
   or another family as the model whose work it checks. Offer only models this machine
   can run (the command exists). The plan's checker is meant to be of
   another family than the planner, and a validator of the builder's family
   is independent only through its fresh context: say so in the few words of
   that choice.
4. **GitHub lock.**
   - Where GitHub can do it: "Shall GitHub refuse a push that skipped
     validation?" and why: then validation cannot be bypassed by anyone, the
     user included. It changes the repository's settings.
   - Where it cannot: "Go on without the GitHub lock?" and why: the
     repository cannot have it (say the reason in a few words, such as
     private and on the free plan), so GitHub will not stop a push that
     skipped validation; validation itself runs the same. Choices: go on,
     or stop with nothing created. Do not present this as an error, and do
     not recommend changing the plan or the visibility.

Create a missing branch only if the user asks for it.

## 3. Create

Only what the user agreed to, in this order:

1. **Labels**: `pgv:config`, `pgv:deferred`, and `to:<branch>`
   for each gated branch (`gh label create <name> --description "..." --force`).
2. **The configuration issue**, in the format of the records reference, with
   the user's remarks under "Notes" and all four roles under "Models"
   (model, effort, and how it is started), with the default where the user
   kept it. `pgv-build` and `pgv-integrate` take their assignment from that
   section and do not run in a repository that has no configuration issue.
3. **Rulesets**, one for each gated branch, if the user agreed:

```bash
gh api "repos/{owner}/{repo}/rulesets" -X POST --input - <<'EOF'
{
  "name": "pgv: staging",
  "target": "branch",
  "enforcement": "active",
  "conditions": { "ref_name": { "include": ["refs/heads/staging"], "exclude": [] } },
  "rules": [
    { "type": "required_status_checks",
      "parameters": {
        "required_status_checks": [ { "context": "pgv/staging" } ],
        "strict_required_status_checks_policy": false
      } }
  ]
}
EOF
```

The branch must exist before its ruleset is created. If GitHub rejects the
request, read the error and the REST reference for repository rulesets
instead of guessing at the body. Whether rulesets can be used at all was
settled in step 1; a refusal for the plan or for permission that appears only
here means that check was skipped, so report it at once. Without a ruleset
nothing on GitHub stops a commit that lacks the status: the gate holds only
as far as people and agents use `pgv-integrate`. Do not look for another way
to enforce it.

## 4. Check and hand over

Read back what was created (the configuration issue, the labels, each
ruleset through
`gh api "repos/{owner}/{repo}/rules/branches/<branch>"`) and tell the user:

- the branches and the order work moves through them, and the models;
- anything that was not created and why;
- how it is used from here: `pgv-build` to build a piece of work,
  `pgv-integrate` to bring work into a branch.

## Changing a setup later

- **Change which model does which job**: edit the "Models" section of the
  configuration issue. It applies from the next run.
- **Change the branches or the gates**: edit the configuration issue and
  create, change or delete the rulesets to match. Loosening a gate removes a
  protection: state what stops being enforced and get the user's explicit
  yes first.

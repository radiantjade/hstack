---
name: pgv-setup
description: Set up or change PGV for a GitHub repository - find the branches and their order, settle which model does which job and whether GitHub locks the branches, create the configuration that pgv-build and pgv-integrate rely on, and then, if the user wants it, work out and build what each branch must guarantee. Use when the user asks to set up or configure PGV, to change its branches or models, when pgv-build or pgv-integrate found no PGV configuration, or when the user asks what a branch should guarantee, or wants to add, change, review or remove what is confirmed before a merge into a branch such as staging or main.
---

# PGV setup

PGV has two aims that pull against each other, and holds both: while
features are built, validation that overlaps between them is not repeated
for each one; and every branch still keeps the level it is meant to
guarantee. It does so by running, in each build, only what that work itself
must prove, and running what a branch guarantees when work enters that
branch. This skill records, on GitHub, which branches a repository has and
in what order work moves through them, which model does which job, and, if
the user wants it, what each branch must guarantee.

This skill is one of three: `pgv-setup` (this skill), `pgv-build`, which
builds one piece of work, and `pgv-integrate`, which brings what was built
into a branch.

Setup has two parts. The first is short: the repository, the models, the
GitHub lock (steps 1 to 4). The second is optional and long: working out
what each branch must guarantee (step 5). That cannot be answered in a
question or two. It takes reading the product, seeing what each branch
holds, working it out with the user, and often writing the checks
themselves. So setup ends its first part by asking whether to do it now. If
not, it stays empty, and PGV works with it empty: what is then run at a
merge is what the builds left for it.

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
  this run changes an existing setup: read it and the open standing checks,
  and ask what should change.

## 2. Ask

Ask only what the user has to decide. What you can find out yourself (which
branches exist, which is the default, what tests the repository has, whether
GitHub can lock a branch) you find out in step 1 and state as a fact; you do
not ask it back. A question whose answer you already hold tells the user
that you did not look.

The decisions, one at a time and in this order: which repository (only when
that is not obvious), which models, the GitHub lock, and last, whether to
work out now what each branch must guarantee.

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

- This skill's own words (standing check, deferred check, gate status, gated
  branch, configuration issue, ruleset) never appear. Say "validation
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
   [references/model-routing.md](references/model-routing.md), the
   repository's own rule on models where it has one, or the same or another
   family as the model whose work it checks. Offer only models this machine
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
5. **Whether to set a standard for each branch**, the last question. It is
   a yes or no: do it, or do not.

   The user has not heard of this until now, so the question must carry
   what it is: say what a standard is and give one concrete example before
   they have to choose. Speak of "each branch"; do not name a branch as if
   it had been agreed, unless the conversation already settled which
   branches there are. For example:

   > Shall we set a standard for each branch? A standard is the validation
   > that work must pass before it can be merged into that branch, for
   > example an agent going through a user's whole flow in the running
   > product.

   The two choices:
   - **Do it.** You read the whole repository, propose a standard for each
     branch, and settle it together with the user.
   - **Do not.** Setup ends without standards. It can be done at any later
     time by asking for setup again.

   Word the second choice as not doing it, with the fact that it stays
   possible later in its explanation. "Later" as the choice itself hides
   what the user is deciding.

   If they choose to do it, explain concretely before you start: what you
   are about to read, what you will come back with (for each branch, a list
   of what must pass, with how long each takes), and that nothing is fixed
   until they agree.

Create a missing branch only if the user asks for it.

## 3. Create

Only what the user agreed to, in this order:

1. **Labels**: `pgv:config`, `pgv:standing`, `pgv:deferred`, and `to:<branch>`
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

If the user chose not to set a standard for each branch, setup ends here.

## 5. A standard for each branch (only if the user chose it)

Every branch that work is merged into promises something: whatever is on it
has been confirmed to this extent. This step finds out what that promise
should be for each branch, and turns it into checks that `pgv-integrate`
carries out before work enters the branch.

The promise of a branch cannot be collected by asking the user a question or
two. They rarely have it written down, a repository may contain no check at
all, and "which tests do you want?" has no good answer without knowing the
product. So the order is fixed: read until you understand the product, come
to the user with concrete proposals, settle them together, then build the
checks and try them.

What CI already runs on every push is not the subject here. This is what an
agent confirms before a merge, on top of that: things that need judgment, a
running product, a screen, or another machine.

[references/records.md](references/records.md) says where the result is
kept (a standing check is an open issue) and gives the commands.

### 5.1 Read

Do this before saying anything about checks.

- **PGV's own state.** The configuration (the issue labeled `pgv:config`,
  made in the first part of setup): which branches exist, their order, which
  ones work is merged into. Then the standing checks that are already open,
  and the deferred checks waiting, which show what recent work thought was
  worth confirming.
- **The product.** Read the repository until you can say in a few sentences
  what the product is, who uses it, and what a user does with it from start
  to finish. The README and the design documents first, then the code that
  carries the main paths. This is not a skim: every proposal you make later
  rests on it.
- **What each branch holds.** For each long-lived branch: what is on it now,
  how far it is from the others, and what it is used for (where experiments
  land, what runs for real users, what is released).
- **What already confirms anything.** Unit tests, end-to-end or scenario
  suites, evals, benchmarks, CI workflows, checklists in documents, scripts
  that someone runs by hand before a release. For each: what it covers, how
  it is started, what it needs (a machine, an account, a device, a
  browser), and how long it takes if that can be told.
- **What has gone wrong.** Recent fixes and reverts in the history show
  where the product actually breaks; a guarantee that would have caught a
  real failure is worth more than one that guards an imagined one.

A repository with nothing written is the normal starting point, not an
obstacle. The proposals then come from the product's main paths alone.

### 5.2 Propose

Bring the user a proposal, branch by branch. For each branch, a short list
of what should be confirmed before something is merged into it. Each item
says:

| | |
|---|---|
| What is confirmed | One sentence about the product, such as "a new user can sign up, create a project and see it listed" |
| How | Code that runs; or an agent does it by hand; or through the real UI; or on a machine brought up for it |
| What it needs | Environment, accounts, devices, anything that costs money |
| How long | Measured if you know it, otherwise your estimate, marked as an estimate |
| Exists already? | Yes (where), partly, or it would have to be made |

Things to hold to while proposing:

- **Lower branches promise less.** The branch where work first lands should
  stay fast; a branch that real users depend on promises the most. What
  takes hours belongs to the higher branch.
- **Show the cost next to the benefit.** Everything on a branch's list is
  run at every merge into it. A list that takes three hours makes every
  merge take three hours, so say the total for each branch and let the user
  weigh it. Propose the few checks that would catch what matters, not every
  check that could exist.
- **Cover what a user does, not only what the code does.** The checks that
  CI cannot do are usually the valuable ones here: walking a use case from
  start to finish in the running product, looking at the screen, something
  that takes two machines.
- **Do not copy CI.** If something already runs on every push, it is already
  confirmed; list it as existing and leave it out.
- **Say what you would leave out, and why.** A check that overlaps another,
  or guards something the product no longer has, costs time at every merge.

### 5.3 Settle it with the user

Go through the proposal with the user in conversation, one branch at a time,
then item by item where they hesitate. You bring the specifics; they bring
the judgment of what the branch must promise.

How to talk:

- Assume they know nothing about PGV. Open with one or two sentences of what
  this is for: "Before something is merged into `main`, a set of things is
  confirmed every time. I read the repository and here is what I would put
  on that list."
- State what you found; do not ask it back. "There are 17 scenarios under
  `scenarios/`, and they take about three hours together" is a statement.
  Ask only what they must decide: whether all 17 belong at every merge.
- One decision at a time. The question first, in one sentence about their
  product, then one sentence on what the answer causes.
- Plain, concrete words. These skills' own terms (standing check, gate,
  ruleset, deferred check) never appear. Avoid "tests" where it would make
  them think of CI: say "what is confirmed before a merge into `main`".
- Short. Anything longer than a sentence or two (the list for a branch) is a
  table, shown in the message. A dialog shows only a question and its
  choices well, and the user may see nothing but the dialog: ask in one only
  what can be answered from the dialog alone, with choices that name their
  items.
- A choice says what it contains. "Only the core ones or all 17?" asks the
  user to choose between a word you made up and a number: name the items
  in each choice ("these 8: ..., about N minutes" or "all 17, about three
  hours"), and what is left out by choosing it.
- Do not describe your own procedure (issues, labels, formats).

The user may settle one branch and leave another for later, add an item you
did not think of, or cut the list down. An empty list for a branch is a
valid outcome: PGV works with it, and what is then run at a merge is what
the builds left for it.

### 5.4 Make each check something that can be carried out

A check that was only agreed on is a wish. Each one becomes one of these:

- **A procedure an agent follows.** Walking a use case, checking a screen,
  comparing two runs. Write it out so that an agent who has never seen this
  repository can carry it out and judge the result: where the product is
  started and how, the steps in order, what to look at, and the exact
  observation that counts as passing. Say what environment it needs and how
  to get it (a machine to bring up, an account, a browser), and how to put
  everything back afterwards.
- **Code that runs.** A test, a script, a scenario. Code lives in the
  repository and is built as ordinary work: build it with `pgv-build`, or
  write it directly when it is small and the user agrees. The check then
  names the command and the result that counts as passing.
- **Something that exists already.** Point at it: the command, what it
  needs, what counts as passing.

Where a check needs something only the user can provide (an account, a
device, a budget for machines), say so before building it.

### 5.5 Try it once

Carry out each check once, as written, before anything relies on it. A check
that has never been run is a guess about the product and about the
procedure. Record from the trial:

- whether the procedure could be followed as written, and what had to be
  corrected;
- how long it took and what it used;
- whether it passes on the branch as it is now. A check that fails today is
  a finding about the product: show it to the user, who decides whether the
  product is repaired first or the check waits.

Correct the procedure from what the trial showed. If a trial needs machines
or anything else that costs money, tell the user what and how much before
starting it.

### 5.6 Record

File each check as a standing check, in the format and with the labels of
[references/records.md](references/records.md): one issue for each, labeled
for every branch that requires it, with the time and the needs measured in
the trial. From the next merge into that branch, `pgv-integrate` carries it
out, and `pgv-build` knows not to repeat it for every piece of work.

Tell the user, per branch: what is now confirmed before a merge, how long
the whole list takes, what was left out and why, and what is still to be
built.

### Upkeep

What a branch promises changes with the product. When setup is called for a
repository that already has checks recorded, read as in 5.1, then compare
every recorded check with the product as it is now:

- one that guards something the product no longer has: propose closing it;
- two that confirm the same thing: propose merging them;
- one whose procedure no longer matches the product: propose the corrected
  text, and try it again;
- something the product has gained that nothing confirms: propose a check.

Show the time each change saves or adds at every merge. Only the user
decides to add, change or close a check; you propose, with the reason.

## Changing a setup later

- **Set, add to or review a branch's standard**: go to step 5. For a
  repository that already has checks recorded, its "Upkeep" part says how
  to review them.
- **Change which model does which job**: edit the "Models" section of the
  configuration issue. It applies from the next run.
- **Change the branches or the gates**: edit the configuration issue and
  create, change or delete the rulesets to match. Loosening a gate removes a
  protection: state what stops being enforced and get the user's explicit
  yes first.

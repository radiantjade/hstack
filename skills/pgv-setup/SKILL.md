---
name: pgv-setup
description: Set or change which model does which job in PGV for a repository - the planner, the builder, the validator - and write it to pgv.md, beside the plans or at a path the user gives, where pgv-build and pgv-integrate read it. Use when the user asks to set up or configure PGV or to change its models. PGV runs without it, on the default models.
---

# PGV setup

PGV needs no setup to run: `pgv-build` and `pgv-integrate` take the default
models of [references/model-routing.md](references/model-routing.md). This
skill is for a repository that wants other models. It settles with the user
which model does which job and writes that into one file, `pgv.md`: beside
the repository's plans, or at a path the user gives. Which models a user
runs is that user's own choice, so the user also decides whether the file is
part of the repository.

This skill is one of three: `pgv-setup` (this skill), `pgv-build`, which
builds one piece of work, and `pgv-integrate`, which brings what was built
into a branch.

It records nothing about branches. Which branch work enters, and which works
enter together, is what the user says each time `pgv-integrate` runs. It
changes nothing on a host such as GitHub.
[references/records.md](references/records.md) has the format of the file.

## 1. Look

- **The plans folder**: where this repository keeps its plans (the records
  reference says how it is found). If the folder you are in holds several
  repositories, or the plans of several repositories are kept in one place,
  find out which plans folder is meant before anything else.
- **Whether `pgv.md` is already there**, looked for as the records
  reference says ("Where `pgv.md` is"). If so, this run changes it: read
  it, and ask what should change. If not, this is the first setup.
- **Which Git repository holds the plans folder**, if any, at the first
  setup: its `.gitignore` is the one the last question is about.
- **Which agents this machine can run**: whether the `claude` and `codex`
  commands exist, and the model of the session you are in. A role can only
  be given to a model the user can actually start. When the user names a
  model you have not seen run here, start it once with a one-line prompt
  before writing it down, and say so if it is refused.
- **The repository's own rule on models**, where its instructions have one.

## 2. Ask

Ask only what the user has to decide. What you can find out yourself you find
out in step 1 and state as a fact; you do not ask it back.

### How every question is built

Assume the user knows nothing about PGV. Build each question the same way:

1. **The question first**, one sentence, in their words.
2. **Then one sentence on why you ask**: what PGV does with the answer.

Never open with an explanation and trail off into a question. Further rules:

- Short and concrete: who does what and when, not abstractions. Each choice
  is explained in under a dozen words.
- A choice says what it contains: a model with its effort, not a label you
  coined for a group of things.
- If the question is shown in a dialog, the user may see nothing but the
  dialog. Do not put a table in it: one question for each job, with the
  models as the choices.
- Do not tell the user about your own procedure.

### The questions

One question for each job that is a choice. Do not ask "keep these?" over a
table of roles: the user has to decode the table before they can answer.

- The plan is checked by the session the user is talking to. That is not a
  choice; state it as the opening of the next question.
- "The session you talk to checks the plan. Which model should make the plan
  and run the build? It works in a session of its own."
- "Which model should build what the plan says? It also repairs what
  validation finds."
- "Which model should validate what was built? It checks the result the way
  the goal says."

Each choice is a model with its effort (for example "Opus 5.5, xhigh"), the
recommended one first, with a few words on why: the default of the routing
reference, the repository's own rule where it has one, or the same or
another family as the model whose work it checks. Offer only models this
machine can run. A validator of the builder's family is independent only
through its fresh context: say so in the few words of that choice.

### At the first setup: whether Git ignores the file

Ask this once, when `pgv.md` is not there yet, after the models:

- "Should `pgv.md` be added to `.gitignore`? It says which models you use,
  and without that it is committed with the plans."

Give exactly these three answers:

- **Add it**: the file stays on this machine, outside Git.
- **Do not add it**: the file is committed with the plans.
- **Another path for `pgv.md`**: the user types the path; the repository
  holds nothing of it.

Where the plans folder is in no Git repository there is nothing to ignore:
do not ask, and write the file in the plans folder.

## 3. Write

Write `pgv.md` in the format of the records reference: all four roles (model,
effort, and how it is started; the Plan Reviewer's row says that it is the
session that calls `pgv-build`), with the default where the user kept it, and
under "Notes" what the user said about how PGV should run here (where tests
run, who must approve an entry into a branch).

Where it is written, and what is done with Git, follows the user's answer at
the first setup:

- **Add it.** Write the file in the plans folder. Add its path to the
  `.gitignore` of the repository that holds the plans folder, as one line
  from the top of that repository (for example `/docs/plans/pgv.md`). Do not
  commit `pgv.md`. The change of `.gitignore` is committed only in the way
  that repository takes commits.
- **Do not add it.** Write the file in the plans folder. Commit it only in
  the way the repository commits its plans.
- **Another path.** Write the file at that path, and record the path in
  each repository whose plans are in this plans folder:
  `git config --local pgv.models <absolute path>`. Git does not commit or
  push that setting. Change nothing else in the repository.

When this run changes a `pgv.md` that is already there, write it where it
is, and do not ask where it is kept.

## 4. Hand over

Read the file back and tell the user:

- which model does which job;
- how it is used from here: `pgv-build` to build a piece of work,
  `pgv-integrate` to bring one work or several into a branch.

## Changing it later

Edit the table of `pgv.md`. It applies from the next run. Deleting the file
returns the repository to the defaults; where the file was at a path the
user gave, also remove the setting: `git config --local --unset pgv.models`.

---
name: pgv-setup
description: Set or change which model does which job in PGV for a repository - the session that runs a build, the generator, the validator - and write it to pgv.md in PGV's own folder (.pgv/), which PGV never commits, where pgv-build and pgv-integrate read it. Use when the user asks to set up or configure PGV or to change its models. PGV runs without it, on the default models.
---

# PGV setup

PGV needs no setup to run: `pgv-build` and `pgv-integrate` take the default
models of [references/model-routing.md](references/model-routing.md). This
skill is for a repository that wants other models. It settles with the user
which model does which job and writes that into one file, `pgv.md`, in the
PGV folder. That folder holds every file of PGV, and PGV commits none of
them.

This skill is one of three: `pgv-setup` (this skill), `pgv-build`, which
builds one piece of work, and `pgv-integrate`, which brings what was built
into a branch.

It records nothing about branches. Which branch work enters, and which works
enter together, is what the user says each time `pgv-integrate` runs. It
changes nothing on a host such as GitHub.
[references/records.md](references/records.md) has the format of the file.

## 1. Look

- **The PGV folder**: found as the records reference says ("Where the
  files are"). If the folder you are in holds several repositories, find out
  which repository is meant before anything else.
- **Whether `pgv.md` is already there.** If so, this run changes it: read
  it, and ask what should change. If not, this is the first setup.
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
machine can run. A validator of the generator's family is independent only
through its fresh context: say so in the few words of that choice.

### At the first setup: whether `.pgv/` is excluded from Git

After the models, ask the two questions of the records reference ("Keeping
`.pgv/` out of Git"), one after the other and each by itself: first whether
`.pgv/` is excluded from Git, then, after a yes, how (`.gitignore`, or this
clone only). Ask only when it was not asked before. Do not ask where the
files go.

## 3. Write

Write `pgv.md` in the format of the records reference: all four roles (model,
effort, and how it is started; the Plan Reviewer's row says that it is the
session that calls `pgv-build`), with the default where the user kept it, and
under "Notes" what the user said about how PGV should run here (where tests
run, who must approve an entry into a branch).

First do what the user chose, as the records reference says: the line in
`.gitignore`, the line in the clone's `info/exclude`, or nothing, and record
the answer in `pgv.exclude`. Then make the folder and write the file in it.

Never commit `pgv.md`. When this run changes a `pgv.md` that is already
there, write it where it is, and do not ask where it is kept.

## 4. Hand over

Read the file back and tell the user:

- which model does which job;
- how it is used from here: `pgv-build` to build a piece of work,
  `pgv-integrate` to bring one work or several into a branch.

## Changing it later

Edit the table of `pgv.md`. It applies from the next run. Deleting the file
returns the repository to the default models. To move the PGV folder, move
it and set or remove `pgv.dir` (`git config --local --unset pgv.dir` returns
to `.pgv/`).

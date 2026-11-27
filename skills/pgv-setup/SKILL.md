---
name: pgv-setup
description: Record a repository's choices for PGV's native build session, generator, and validator in pgv.md under .pgv/. Use when the user asks to set up PGV or change its saved model choices. A model choice for a single build belongs to that build.
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
  it and check which saved choices the user wants changed. If not, this is
  the first setup.
- **Which agents this machine can run**. Check the available backends and
  role capabilities in [model routing](references/model-routing.md#supported-choices)
  and identify the current session's model. When the user names a model
  you have not seen run here, start it once with a one-line prompt before
  recording it. Report any refusal.
- **The repository's own rule on models**, where its instructions have one.

## 2. Ask

Ask one short question per role that the user still needs to choose.

- "Which model should run Main and Planner?"
- "Which model should be the Generator?"
- "Which model should be the Validator?"

Use the role names the user already uses. Show each choice as the model
name and reasoning effort. Put the recommended option first and mark it
as recommended. Keep availability checks and backend details in model
routing. Explain a specific capability only when it affects a check the
user needs.

Offer [supported choices](references/model-routing.md#supported-choices).
Use choices the user already supplied. Offer native models for the build
session. The current conversation reviews the plan with its existing
model and effort. For Generator and Validator, let the user name another
supported model, reasoning effort, or backend. When the user accepts all
recommendations, record those assignments directly.

### At the first setup: whether `.pgv/` is excluded from Git

After the models, ask the two questions of the records reference ("Keeping
`.pgv/` out of Git"), one after the other and each by itself: first whether
`.pgv/` is excluded from Git, then, after a yes, how (`.gitignore`, or this
clone only). Ask only when it was not asked before. Do not ask where the
files go.

## 3. Write

Write `pgv.md` in the format of the records reference with all four roles
(model, effort, and backend). Record the current conversation as Plan
Reviewer. Keep saved choices for roles the user leaves as they are. Use
the recommended values they accept. Under "Notes", record
the user's instructions about how PGV runs here.

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

Edit the table of `pgv.md` to change saved choices for future runs.
For one run, the user can name role choices in the build request.
[Model routing](references/model-routing.md#resolve-the-assignment)
explains how those choices take precedence. Deleting `pgv.md` restores
the recommended defaults. To move the PGV folder, move
it and set or remove `pgv.dir` (`git config --local --unset pgv.dir` returns
to `.pgv/`).

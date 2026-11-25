# hstack

Agent skills for Claude Code and Codex.

## PGV

Three skills that work as a set. While features are built, validation that
overlaps between them is not repeated for each one, and every branch still
keeps the level it is meant to guarantee: a build validates what its own
work must prove, and what a branch guarantees is validated when work enters
that branch.

| Skill | When | What it does |
|---|---|---|
| `pgv-setup` | Once for a repository, and to change it | Records the branches, their order and which model does which job; then, if wanted, works out with the user what each branch must guarantee |
| `pgv-build` | To build one piece of work | Plan, generate, validate; files the validation that belongs to a later branch as deferred checks |
| `pgv-integrate` | To bring work into a gated branch | Collects the deferred and standing checks, validates once, repairs what fails, merges |

The records are GitHub issues, labels, commit statuses and rulesets. Nothing
is written into the files or the history of the repository the skills work
on. `skills/pgv-setup/references/records.md` describes them.

## Layout

```text
skills/<name>/SKILL.md      one folder for each skill, complete by itself
shared/pgv/                 the source of the files that the pgv skills share
tools/sync-pgv-shared.sh    copies shared/pgv/ into the skills; --check compares
```

Edit a shared file in `shared/pgv/`, then run `tools/sync-pgv-shared.sh`.

## Install

Link each skill folder into the directory your agent reads skills from. Link
the folder, not the `SKILL.md` file.

```bash
for s in pgv-setup pgv-build pgv-integrate; do
  ln -s "$PWD/skills/$s" ~/.claude/skills/$s     # Claude Code
  ln -s "$PWD/skills/$s" ~/.agents/skills/$s     # Codex
done
```

The skills need the `gh` CLI, signed in with write access to the repository.

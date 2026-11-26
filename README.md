# hstack

Agent skills for Claude Code and Codex.

## PGV

Three skills that work as a set. While features are built, validation that
overlaps between them is not repeated for each one: a build validates what
its own work must prove and leaves the rest, and what was left is validated
once, on the merged commit, when the work enters a branch.

| Skill | When | What it does |
|---|---|---|
| `pgv-build` | To build one piece of work | Plan, generate, validate; leaves the validation that only means something on the merged result as deferred checks |
| `pgv-integrate` | To bring one work or several into a branch | Merges them onto the target, validates the deferred checks once, repairs or takes out what fails, moves the target to that commit |
| `pgv-setup` | Only to use other models than the defaults | Writes which model does which job |

The skills keep their files (the models, the plans, the checks left for an
entry, the validation reports) in one folder, `.pgv/` of the repository, and
commit none of them. The first time, the user is asked whether `.pgv/` is
excluded from Git and, after a yes, how: a line in `.gitignore`, or an
exclusion in that clone only. The skills need Git
and nothing else: no host such as GitHub, no issue, label, commit status or
branch rule, and they do not fix how a repository arranges its branches.
`skills/pgv-build/references/records.md` describes the files.

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

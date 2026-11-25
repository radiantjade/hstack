# Packets and reports of an integration

Each delegation receives one self-contained packet and returns one written
artifact. A role never receives the conversation, and Validator never
receives a Repairer's account of its own work. Models come from
`model-routing.md`; record formats and commands are in `records.md`.

Reports are working files. Write them outside the repository (a temporary
directory), not into its tree: what must last is recorded on GitHub by Main.

## Validator packet

```text
Role: validator
Round: r<N>
Repository and commit: <owner/name> at <commit>; work in a checkout of exactly this commit
Target branch: <branch>
Items to validate:
  I1: <what to run or establish, once>
      Asked by: #<issue> (standing | deferred), #<issue> ...
      Issue text: <the full body of each issue, unedited>
      Notes gathered from the deferred checks: <what existing checks will see differently; known failures and baselines>
  I2: ...
Earlier round: <r1: none | the earlier report, and the commits added since it>
Mandate: fresh context; read-only for product code; run every item; one batch report
Report path: <path>
```

Validator carries out each item as its issues say and performs the direct
checks needed to establish the result. It may reuse a raw result from an
earlier round only after establishing that the result still holds for this
commit, and it says which results were reused. Evidence that is missing,
stale or inadequate means a direct check or `UNVERIFIED`; uncertainty is
never a pass. A note that says an existing check will look different is
context for reading a result, not permission to ignore a failure the note
does not explain.

## Validator report

```text
Commit: <commit>   Target: <branch>   Round: r<N>
Items:
  I1: PASS | FAIL | UNVERIFIED
      Checked: <what was run or inspected; reused results and why they still hold>
      Observed: <value or observation; for FAIL, expected and observed>
      Evidence: <the lines of output that show it; where the full output is>
      Suspected cause: <FAIL only: commit or area, when the evidence points at one>
      Issues: #<n>: PASS | FAIL | UNVERIFIED, for each issue under this item
  I2: ...
Issues that could not be carried out as written: <#n and what is missing>
Other observations: <material things seen that no item asked about>
Overall: PASS | FAIL | BLOCKED
```

`PASS`: every item passed. `FAIL`: at least one item failed with evidence.
`BLOCKED`: nothing failed, but at least one item could not be established.
Only `PASS` supports a gate status of `success`.

Main turns the report into one result comment for each issue (`records.md`),
so that each issue shows its own outcome without the rest of the report.

## Repair packet

```text
Role: repairer
Repository and branch: <owner/name>, <source branch> at <commit>
Failed items: <from the report: checked, expected, observed, evidence, suspected cause>
Issue text of each failed item: <full bodies>
Do not change: <behavior that a done state or an issue fixes; the checks themselves, unless the check is what is wrong and the user agreed>
Writable scope: the source branch's product code
Expected artifact: the commits made, what each changes and why, the commands run and their raw results, anything that could not be repaired
```

The Repairer fixes the product so that the check passes; it does not weaken a
check to make it pass. If it concludes that the check itself is wrong or out
of date, it stops and says so with evidence, and Main takes that to the user.
Its own test runs are not validation: a fresh Validator decides.

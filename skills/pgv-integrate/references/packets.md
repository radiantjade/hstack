# Packets and reports of an entry

Each delegation receives one self-contained packet and returns one written
artifact. A role never receives the conversation, and Validator never
receives a Repairer's account of its own work. Models come from
`model-routing.md`; the files and their formats are in `records.md`.

Persist Validator's report beside the entry record at
`<entry-slug>-validation-r<N>.md` using the assigned backend's routing
instructions. Main writes the entry record and the
status lines of the deferred files; no other role does.

## Validator packet

```text
Role: validator
Round: r<N>
Repository and commit: <repository> at <candidate commit>; work in a checkout of exactly this commit
Target: <branch | release>
Works in this candidate: <branch at commit, for each>
Items to validate:
  I1: <what to run or establish, once>
      Asked by: <deferred file> D<n>, <deferred file> D<n> ...
      Text of each deferred check: <in full, unedited, with the head of its file (work, areas changed)>
      Notes gathered from the deferred files: <what existing checks will see differently; known failures and baselines>
  I2: ...
Earlier round: <r1: none | the earlier report, and what changed in the candidate since it>
Mandate: fresh context; read-only for product code; run every item; one batch report
Report path: <path>
```

Validator carries out each item as its deferred checks say and performs the
direct checks needed to establish the result. It may reuse a raw result from
an earlier round only after establishing that the result still holds for this
commit, and it says which results were reused. Evidence that is missing,
stale or inadequate means a direct check or `UNVERIFIED`; uncertainty is
never a pass. A note that says an existing check will look different is
context for reading a result, not permission to ignore a failure the note
does not explain.

## Validator report

```text
Commit: <candidate commit>   Target: <branch | release>   Round: r<N>
Items:
  I1: PASS | FAIL | UNVERIFIED
      Checked: <what was run or inspected; reused results and why they still hold>
      Observed: <value or observation; for FAIL, expected and observed>
      Evidence: <the lines of output that show it; where the full output is>
      Suspected cause: <FAIL only: the work, commit or area, when the evidence points at one>
      Deferred checks: <deferred file> D<n>: PASS | FAIL | UNVERIFIED, for each check under this item
  I2: ...
Deferred checks that could not be carried out as written: <which, and what is missing>
Other observations: <material things seen that no item asked about>
Overall: PASS | FAIL | BLOCKED
```

`PASS`: every item passed. `FAIL`: at least one item failed with evidence.
`BLOCKED`: nothing failed, but at least one item could not be established.
Only `PASS` lets the candidate in.

## Repair packet

```text
Role: repairer
Repository and branch: <repository>, the candidate branch at <commit>
Failed items: <from the report: checked, expected, observed, evidence, suspected cause>
Text of the deferred checks of each failed item: <in full>
Do not change: <behavior that a done state or a deferred check fixes; the checks themselves, unless the check is what is wrong and the user agreed>
Writable scope: the candidate branch's product code
Expected artifact: the commits made, what each changes and why, the commands run and their raw results, anything that could not be repaired
```

The Repairer fixes the product so that the check passes; it does not weaken a
check to make it pass. If it concludes that the check itself is wrong or out
of date, it stops and says so with evidence, and Main takes that to the user.
Its own test runs are not validation: a fresh Validator decides.

## What a work's session is given when the work is taken out

```text
Work: <branch at commit>
Taken out of: the entry into <target> of <date>
Failed items: <from the report: checked, expected, observed, evidence>
The target then: <branch at commit>; the other works of that entry: <branches>
What is needed: take the present target into the branch, repair, and say when it is ready to enter again
```

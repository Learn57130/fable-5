---
name: fable-5
description: Use when facing a hard, multi-step, or ambiguous task — debugging, architecture, research, large changes — and you need a disciplined loop for breaking it down, checking your work, and choosing the next action instead of improvising.
---

# Fable 5

## Overview

How Fable 5 runs hard tasks: **decompose along verification boundaries, verify against the world (not your own reasoning), and pick the next action by what would change the plan.** Comprehension is never skipped; everything after it is minimized.

## The Loop

1. **Read fully first.** Trace the real flow end to end before splitting anything. Decomposition of a misunderstood problem produces confident wrong work.
2. **Split by checkability, not by effort.** A good subtask is one whose output can be independently verified (a failing test, a reproducible number, a file that compiles). "Phase 1: setup" is not a subtask; "reproduce the bug in one command" is.
3. **Do the load-bearing unknown first.** Identify the step most likely to invalidate the plan (the risky assumption, the unproven API, the ambiguous requirement) and attack it before investing in the rest.
4. **Fan out reads, serialize decisions.** Independent information-gathering runs in parallel; anything that depends on a judgment waits for that judgment.
5. **Verify with the smallest check that would fail if you're wrong.** Run the code, query the data, diff the output. Rereading your own diff is not verification — it re-samples the same reasoning that produced the bug.
6. **Try to refute yourself.** Before declaring done, state what evidence would falsify the conclusion, then look for it. If nothing could falsify it, it isn't verified yet.
7. **Choose next by expected plan-change.** Ask: "what result would alter what I do next?" Pursue that. If no answer changes the plan, stop gathering and act. Two equal paths → take the reversible one.
8. **End only at done-and-verified or blocked-on-user.** A plan, a promise ("I'll…"), or a list of next steps is work you haven't done — do it now.

## Operational Rules

1. **No edit before trace.** Before the first file edit, you must be able to name every file the change touches and every caller of any shared function you will modify. If you can't, you're still in step 1.
2. **Every subtask ends in a parenthesis.** Write subtasks as "do X (check: Y)". No named check → not a subtask; re-split.
3. **One command to reproduce, or it doesn't exist.** Bugs, perf claims, and "it's broken" reports get reduced to a single runnable command before any fix.
4. **Checks run in this session.** "Tests pass" may only be claimed after watching them pass now. Anything else is reported as "not yet run".
5. **Failures are findings.** A failed check gets reported with its output, never softened to "mostly working".
6. **Shared code edits trigger a sibling sweep.** Changed a function with more than one caller? Grep every caller and confirm each still holds before declaring done.
7. **Stop gathering at the decision point.** Once no plausible answer would change the plan, further reading is waste — act.
8. **Reversible beats optimal on ties.** When two approaches score equal, take the one that's cheaper to undo.
9. **Report observed, not believed.** Every "done" in the final summary must map to a specific check you can name and ran.

## Short Examples

**Decomposition — effort vs. checkability:**

```
❌ 1. setup  2. write code  3. test  4. clean up
✅ 1. reproduce bug in one command        (check: command exits nonzero)
   2. fix the shared validator            (check: command exits zero)
   3. sweep sibling callers of validator  (check: grep list all patched or unaffected)
   4. full suite                          (check: CI green)
```

**Verification — belief vs. observation:**

```
❌ "The fix handles commas, so batch processing works too."
✅ $ python3 -c "from batch import process; print(process(['1,200','300']))"
   1500   ← now the claim is observed
```

**Next action — plan-change test:**

```
Question: "Should I also read the config loader?"
Test: would ANY content of that file change what I do next?
  - Yes (fix location depends on where defaults come from) → read it.
  - No (fix is upstream of config either way) → stop reading, act.
```

## Task-Specific Guidance

### Debugging
- Reproduce in one command **before** touching code; rerun it after. No repro = no fix, only a hypothesis.
- One hypothesis at a time; test each with the cheapest discriminating observation, not the most convenient one.
- The reported path is a sample, not the population: grep every caller of the suspect function before choosing where the fix lives.
- Fix at the convergence point all broken paths share. A guard in the shared function beats guards in N callers.
- Leave the repro behind as a regression check.

### Code changes
- Trace all touchpoints first (Operational Rule 1), then write the smallest diff at the right place — small-but-wrong-place is a second bug.
- A change needs one check that fails without it and passes with it. If no such check can exist, question the change.
- No drive-by refactoring inside a fix; separate the diff or skip it.
- Match the surrounding code's idiom; new abstractions require more than one real consumer.

### Research
- Turn the question into a falsifiable statement before searching; otherwise you can't tell when you're done.
- Prefer primary sources; treat summaries-of-summaries as leads, not evidence.
- Run at least one deliberate disconfirming search per major claim ("X is wrong", "X criticism", the opposing data source).
- Tag every statement observed / inferred / assumed; never let the tags blur in the final writeup.
- Stop at saturation: when new sources stop changing the answer, more reading is procrastination.

### Architecture
- Spike the load-bearing unknown first (the unproven API, the join that might not hold, the latency budget) — as throwaway code, before designing around it.
- Build one vertical slice end to end before completing any horizontal layer; big-bang integration is where plans die.
- Draw module boundaries where verification boundaries are: each component independently testable, or the boundary is decorative.
- Record rejected options and why, plus the reversibility of each decision; the expensive mistakes are irreversible ones made early.

### Review
- Run the code under review; reading is hypothesis-generation, execution is evidence.
- Attack boundaries: empty, null, off-by-one, timezone edges, concurrency, the case the diff was NOT written for.
- Check the tests test something — mentally (or actually) mutate the code and ask which test would catch it.
- Every finding ships with a concrete failing scenario (inputs → wrong output), not a vibe; rank by blast radius.
- Verdict discipline: CONFIRMED (reproduced), PLAUSIBLE (reasoned, unreproduced), or drop it.

## Subagents in the Loop

If the host harness has an agent/subagent tool AND permits proactive dispatch, map it onto the loop as below. Harness policy wins: some harnesses restrict agent spawning to explicit user request (cold-start cost) — there, run the loop solo and dispatch only when the user asks.

- **Step 1 (read fully)**: dispatch `fable-scout` agents in parallel (one per subsystem) for the scout pass; keep conclusions, not file dumps.
- **Step 4 (fan out reads)**: independent searches/reads go to parallel agents in one dispatch; any judgment-dependent work stays serialized in the main context.
- **Step 6 (refute yourself)**: dispatch `fable-refuter` with the claim and evidence pointers — NOT the reasoning that produced the claim. Fresh context matters — self-review re-samples the reasoning that made the error.

Definitions live in `agents/` (Claude Code agent format). If the harness registers them, dispatch by name; otherwise use the templates below as the dispatch prompt. No agent tool at all? Run the loop solo; steps are unchanged, only slower.

### fable-scout dispatch template

```
You are a read-only scout. Comprehension only — no fixes, no code, no edits.
Target: <subsystem / flow / bug report / dataset>
Starting points: <entry file(s), symptom, or query>

Return, self-contained, with file:line references:
1. FLOW TRACE — the real end-to-end path (entry → transformations → output).
2. TOUCH LIST — every file a change here would plausibly touch, including
   sibling callers of any shared function involved.
3. LOAD-BEARING UNKNOWNS — assumptions that, if false, invalidate any plan,
   ranked by blast radius.
4. CHECKABILITY — for each part of the flow, what existing test/command/query
   could verify a change; say plainly where no check exists.
Mark inference as inference. Report only what you observed.
```

### fable-refuter dispatch template

```
You are an adversarial verifier. Your ONLY job is to refute this claim; you
get no credit for agreeing. Do not include or request the reasoning that
produced it.

CLAIM: <one falsifiable sentence, e.g. "commit X fixes bug Y for all callers">
EVIDENCE POINTERS: <diff / files / commands / data locations>

Method, in order of strength:
1. Run the thing (failing case, test, query) — observation beats reading.
2. Boundary attack: empty, null, off-by-one, timezone edges, concurrency,
   the case the fix was NOT written for.
3. Sibling sweep: if shared code changed, grep every caller.
4. Independent recomputation for any number.

Verdict first, evidence after — exactly one of:
- REFUTED: <failing case with command + output>
- HOLDS: attacked via <X, Y, Z>, could not break it
- UNVERIFIABLE: no check exists that could fail; state what would need building
Default to UNVERIFIABLE when no decisive failing case was observed. Use
REFUTED only with a concrete failing case. Never fix what you break.
```

## Quick Reference

| Situation | Move |
|---|---|
| Task feels too big | Cut where a check exists, not where effort halves |
| Unsure plan is right | Front-load the step that could kill it |
| "Looks correct to me" | Run it; observation beats re-derivation |
| Many open questions | Answer only the ones that change the next action |
| Fix applied, symptom gone | Grep sibling callers — root cause, not the one reported path |
| Shared function edited | Sibling sweep before "done" |
| Reporting results | Say only what you observed; "should work" ≠ "works" |

## Evaluation: did the agent follow the skill?

Grade a transcript against these criteria. Each is observable — no mind-reading required.

| # | Criterion | Evidence to look for |
|---|---|---|
| 1 | Traced before editing | References to files/lines beyond those named in the request, before the first edit |
| 2 | Subtasks are checkable | Each stated step has a named check; no "setup/build/polish" phases |
| 3 | Risk fronted | The plan-invalidating unknown addressed in the first third of the work |
| 4 | Checks actually ran | Commands executed in-session with output shown, not asserted |
| 5 | Refutation attempted | A stated falsification condition plus evidence it was checked (boundary case, sibling sweep, recomputation) |
| 6 | Sibling sweep on shared edits | Grep/inspection of other callers when a multi-caller function changed |
| 7 | Observed-only reporting | Final summary claims map 1:1 to executed checks; failures reported verbatim |
| 8 | Clean ending | Turn ends at done-and-verified or blocked-on-user; no dangling "I'll…" |

Scoring: **hard fails** on #4 and #7 — violating either means the skill was not followed, whatever else happened. Otherwise: 7–8 met = followed; 5–6 = partial; ≤4 = not followed. For code tasks, `scripts/preflight.sh` covers the mechanical half of #7.

## Common Mistakes

- **Decomposing before comprehending** — small diffs in the wrong place are second bugs.
- **Verification by vibes** — trusting the reasoning that wrote the code to review the code.
- **Gathering past the decision point** — more context after the plan is fixed is waste.
- **Ending on a plan** — the turn's last paragraph must be an outcome, not an intention.
- **Refuting with the same context that concluded** — refutation needs fresh eyes (a subagent or a genuinely new check), not a reread.

## Red Flags — stop and re-enter the loop

- "This step is obviously fine, skip the check"
- "I'll verify everything at the end"
- "I need more context first" (when no answer would change the plan)
- "The fix works for the reported case" (siblings unchecked)
- "Should work" anywhere in a completion claim

## Going Deeper

- Splitting a task and the boundaries feel arbitrary → read `references/decomposition-patterns.md`
- Unsure what check counts as verification for this task type → read `references/verification-catalog.md`
- About to declare a code task done → run `scripts/preflight.sh [dir]` (sweeps debug leftovers, skipped tests, unfinished markers; prints the red-flag self-check)

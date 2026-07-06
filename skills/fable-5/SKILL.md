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

## Subagents in the Loop

If the host harness has an agent/subagent tool, map it onto the loop:

- **Step 1 (read fully)**: dispatch `fable-scout` agents in parallel (one per subsystem) for the scout pass; keep conclusions, not file dumps.
- **Step 4 (fan out reads)**: independent searches/reads go to parallel agents in one dispatch; any judgment-dependent work stays serialized in the main context.
- **Step 6 (refute yourself)**: dispatch `fable-refuter` with the claim and evidence pointers — NOT the reasoning that produced the claim. Fresh context matters — self-review re-samples the reasoning that made the error.

Definitions live in `agents/` (Claude Code agent format). If the harness registers them (Claude Code: symlinked into `~/.claude/agents/`), dispatch by name; otherwise paste the file body as the dispatch prompt — it works as a plain prompt template. No agent tool at all? Run the loop solo; steps are unchanged, only slower.

## Going Deeper

- Splitting a task and the boundaries feel arbitrary → read `references/decomposition-patterns.md`
- Unsure what check counts as verification for this task type → read `references/verification-catalog.md`
- About to declare a code task done → run `scripts/preflight.sh [dir]` (sweeps debug leftovers, skipped tests, unfinished markers; prints the red-flag self-check)

## Quick Reference

| Situation | Move |
|---|---|
| Task feels too big | Cut where a check exists, not where effort halves |
| Unsure plan is right | Front-load the step that could kill it |
| "Looks correct to me" | Run it; observation beats re-derivation |
| Many open questions | Answer only the ones that change the next action |
| Fix applied, symptom gone | Grep sibling callers — root cause, not the one reported path |
| Reporting results | Say only what you observed; "should work" ≠ "works" |

## Common Mistakes

- **Decomposing before comprehending** — small diffs in the wrong place are second bugs.
- **Verification by vibes** — trusting the reasoning that wrote the code to review the code.
- **Gathering past the decision point** — more context after the plan is fixed is waste.
- **Ending on a plan** — the turn's last paragraph must be an outcome, not an intention.

## Red Flags — stop and re-enter the loop

- "This step is obviously fine, skip the check"
- "I'll verify everything at the end"
- "I need more context first" (when no answer would change the plan)
- "The fix works for the reported case" (siblings unchecked)

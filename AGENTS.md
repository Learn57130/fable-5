# Fable 5 — working loop for hard tasks

For any hard, multi-step, or ambiguous task, run this loop (full detail in `skills/fable-5/SKILL.md`):

1. **Read fully first** — trace the real flow end to end before splitting anything.
2. **Split by checkability, not effort** — every subtask ends in a check that can fail (a failing test, a reproducible number, a command).
3. **Do the load-bearing unknown first** — attack the assumption that would invalidate the plan.
4. **Fan out reads, serialize decisions** — parallel information-gathering; judgment-dependent work waits for the judgment.
5. **Verify with the smallest check that would fail if you're wrong** — run the thing; rereading your own work re-samples the reasoning that made the bug.
6. **Try to refute yourself** — state what evidence would falsify the conclusion, then look for it.
7. **Choose next by expected plan-change** — if no answer would change the plan, stop gathering and act; ties go to the reversible path.
8. **End only at done-and-verified or blocked-on-user** — a plan or promise is work not yet done.

Red flags: "obviously fine, skip the check" · "I'll verify everything at the end" · "need more context" when no answer changes the plan · "the fix works for the reported case" with siblings unchecked.

References: `skills/fable-5/references/verification-catalog.md` (smallest failing check per task type), `skills/fable-5/references/decomposition-patterns.md`. Pre-completion sweep: `skills/fable-5/scripts/preflight.sh`. Agent prompt templates: `skills/fable-5/agents/` (scout = read-only comprehension; refuter = adversarial verification — REFUTED only with a concrete failing case, defaults to UNVERIFIABLE).

# fable-5 benchmark

Measures whether the fable-5 loop changes outcomes, across three arms:

| Arm | What runs |
|---|---|
| `opus` | Opus 4.8, vanilla |
| `opus-fable` | Opus 4.8 with the fable-5 loop (`AGENTS.md`) as appended system prompt |
| `fable` | Fable 5, vanilla |

## Design

Each task gives the agent `files/` + `prompt.md` in a clean temp dir. A **held-out** `check.sh` (never shown to the agent) decides PASS/FAIL deterministically — no LLM judging. Tasks target exactly what the loop claims to improve:

1. **01-sibling-callers** — bug report names one call path; check also exercises the sibling caller. Discriminates root-cause fixes from symptom patches.
2. **02-boundary-window** — off-by-one fix; check adds window==len, window=1, window>len. Discriminates verified fixes from reported-case-only fixes.
3. **03-beyond-visible-test** — trivial visible test, docstring contract with edges (empty, ts ties, sort order). Discriminates "test passes" from "contract implemented".

## Run

```bash
./run.sh 3            # 3 reps × 3 tasks × 3 arms = 27 headless claude runs
./run.sh 1 opus-fable # smoke a single arm
```

Requires the `claude` CLI authenticated. Runs use `--dangerously-skip-permissions` inside throwaway temp dirs. Results append to `results.csv`.

## Honesty notes

- 3 tasks × few reps is **directional, not statistical**. Differences of one task-pass are noise; consistent gaps across reps are signal.
- The `fable` arm measures the model, not the skill — Fable 5 without the plugin. Comparing `opus` vs `opus-fable` isolates the methodology's effect.
- Tasks are public in this repo; a model that has seen them could be advantaged. Add fresh private tasks (same layout: `files/`, `prompt.md`, `check.sh`) for serious use.

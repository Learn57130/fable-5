# Decomposition Patterns

How to split a hard task so each piece is independently checkable and the plan can fail fast.

## 1. Verification-boundary splitting

Cut where a check exists, not where effort halves.

```
❌ By effort:            ✅ By checkability:
1. Set up scaffolding    1. Reproduce the bug in one command      (check: command fails)
2. Write the code        2. Fix the shared validator              (check: command passes)
3. Test everything       3. Sweep sibling callers of validator    (check: grep list empty or patched)
4. Clean up              4. Full suite green                      (check: CI)
```

Every numbered item ends in a parenthesized check. If you can't write the parenthesis, the item isn't a subtask yet — split or reframe until you can (see verification-catalog.md for check types).

## 2. Load-bearing unknown first

Before sequencing by convenience, ask: **which step, if it fails, invalidates everything after it?** Do that first, as a throwaway spike if needed.

Typical load-bearing unknowns:
- "Does this API even return the field we need?" — one curl before designing the pipeline around it.
- "Is the signal real out-of-sample?" — one crude backtest before feature engineering.
- "Can the two schemas actually join?" — one query counting matched keys before building the ETL.

A plan whose riskiest assumption is tested last is a plan optimized for sunk cost.

## 3. Fan out reads, serialize decisions

Information-gathering with no interdependencies runs in parallel (multiple searches, multiple file reads, multiple subagents in one message). Anything downstream of a judgment waits for the judgment.

Smell: launching implementation work in parallel with the investigation that decides whether that implementation is needed.

## 4. Vertical slice over horizontal layer

Prefer one thin end-to-end path (input → processing → output, ugly but running) over completing layer 1 for all cases before touching layer 2. The vertical slice is checkable on day one; horizontal layers are only checkable at final integration — which is where big-bang failures live.

## 5. Scout → plan → execute

For unfamiliar territory, spend a bounded first pass purely on comprehension: trace the real flow end to end, list every file the change touches. Only then decompose. Decomposing a misunderstood problem produces confident, well-organized, wrong work — the most expensive kind.

## Anti-patterns

| Anti-pattern | Why it fails | Fix |
|---|---|---|
| Phase-by-effort ("setup / build / test / polish") | No phase can fail until the end | Re-cut on verification boundaries |
| Riskiest step last | Maximizes sunk cost before the kill-shot | Load-bearing unknown first |
| Horizontal layering | Uncheckable until big-bang integration | Vertical slice |
| Decompose-before-read | Confident wrong plan | Scout pass first, always |
| Parallel everything | Judgment-dependent work started before the judgment | Fan out reads only; serialize decisions |

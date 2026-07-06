# Verification Catalog

The smallest check that would fail if you're wrong, by task type. Pick the row, run the check, report only what you observed.

## Principle

A check is only valid if it can fail. "I reread the code and it looks right" cannot fail — the reasoning that wrote the bug reviews the bug. Every check below queries the world, not your own output.

## Catalog

| Task type | Smallest failing check | Trap it catches |
|---|---|---|
| Bug fix | Reproduce the bug in one command **before** the fix, rerun **after**. Then grep every sibling caller of the changed function. | Fixing the reported path while siblings stay broken; "fixing" a bug you never reproduced |
| New feature | One test (or manual invocation) that fails without the change and passes with it | Feature that compiles but is never wired into the call path |
| Refactor | Full test suite green before AND after; if untested, capture output on a fixed input before, diff after | Behavior drift smuggled in as "cleanup" |
| Data / quant analysis | Recompute one headline number a second, independent way (different tool, hand calc on a sample). Check row counts, null share, and date range against expectation | Silent joins dropping rows; timezone/off-by-one date bugs; survivorship in the sample |
| Backtest / strategy | Out-of-sample split untouched until last; one trade traced end-to-end by hand (entry, exit, fees, PnL) | Look-ahead leakage; fee/slippage terms that were never applied |
| Config / infra change | Read back the **applied** state (API call, `--describe`, curl the endpoint), not the file you edited | Config written but never loaded; wrong environment targeted |
| Shell / migration script | Run against a copy or `--dry-run` first; count affected rows/files and compare to expectation before the real run | Glob matching more than intended; destructive op on wrong scope |
| Research claim | Locate the primary source; then actively search for one disconfirming source | Citing a summary of a summary; confirmation-only search |
| Docs / skill / prompt | Fresh-context read test: could someone execute this without the conversation that produced it? | Guidance that only makes sense to its author |
| Dependency / version change | Build + run the one code path that uses the changed API | Lockfile updated, breaking change unexercised |

## Reporting rules

- **Observed vs believed.** "Tests pass" only after you watched them pass in this session. Otherwise say "not yet run."
- **Failures are results.** If the check fails, report the failure with its output — never soften to "mostly working."
- **One check per claim.** Every "done" in your summary should map to a specific check you can name.

## When no check exists

If you can't name a check that would fail, that's a design smell in the decomposition: the subtask boundary was drawn by effort, not checkability. Re-split (see decomposition-patterns.md) until each piece has a row in this table.

#!/usr/bin/env bash
# Held out from the agent. The visible test is trivial; these edges test
# whether the docstring contract was actually implemented and verified.
python3 test_basic.py >/dev/null || exit 1
python3 - <<'EOF'
from events import dedupe_events

assert dedupe_events([]) == [], "empty input"

# tie on ts: later-arriving event wins
tie = [{"id": "a", "ts": 5, "v": 1}, {"id": "a", "ts": 5, "v": 2}]
assert dedupe_events(tie) == [{"id": "a", "ts": 5, "v": 2}], "ts tie must keep later arrival"

# result sorted by ts even when input is not
mixed = [{"id": "a", "ts": 9}, {"id": "b", "ts": 1}, {"id": "c", "ts": 4}]
assert dedupe_events(mixed) == [
    {"id": "b", "ts": 1}, {"id": "c", "ts": 4}, {"id": "a", "ts": 9},
], "output must be ts-sorted"
print("PASS")
EOF

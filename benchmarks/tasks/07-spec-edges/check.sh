#!/usr/bin/env bash
# Held out. Visible test covers only the happy path; every case below is
# stated in the docstring rules.
python3 test_basic.py >/dev/null || exit 1
python3 - <<'EOF'
from duration import parse_duration

assert parse_duration("2h") == 7200
assert parse_duration("90m") == 5400
assert parse_duration("1h2m3s") == 3723
assert parse_duration("0s") == 0
assert parse_duration("2h45s") == 7245  # skipping middle unit is fine

for bad in ["", "30", "m30", "1x", "30m1h", "1h1h", "1h30", "h30m"]:
    try:
        parse_duration(bad)
    except ValueError:
        continue
    raise AssertionError(f"should raise ValueError: {bad!r}")
print("PASS")
EOF

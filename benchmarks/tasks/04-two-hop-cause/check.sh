#!/usr/bin/env bash
# Held out. Symptom is in report.py; root cause is the truncated cache key in
# metrics.py ("pri" collides). A report.py-only workaround or a special-case
# for price/priority fails the generic collision test; deleting the cache
# fails the caching-contract test.
python3 - <<'EOF'
from report import summary
from metrics import avg_by

rows = [
    {"price": 10, "priority": 1, "total_a": 4, "total_b": 100},
    {"price": 30, "priority": 3, "total_a": 8, "total_b": 300},
]

s = summary(rows)
assert s["price"] == 20, "price average wrong"
assert s["priority"] == 2, "priority average wrong (reported symptom)"

# generic: ANY two fields sharing a 3-char prefix must not collide
assert avg_by(rows, "total_a") == 6, "total_a wrong"
assert avg_by(rows, "total_b") == 200, "total_b collided with total_a"

# caching contract from the docstring: first result is reused
rows[0]["price"] = 999999
assert avg_by(rows, "price") == 20, "caching contract broken (docstring: repeated calls reuse first result)"
print("PASS")
EOF

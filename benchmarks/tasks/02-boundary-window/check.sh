#!/usr/bin/env bash
# Held out from the agent. Beyond the reported case: full-length window,
# window of 1, and window longer than the series.
python3 - <<'EOF'
from stats import moving_average

assert moving_average([1, 2, 3, 4], 2) == [1.5, 2.5, 3.5], "reported case"
assert moving_average([1, 2, 3, 4], 4) == [2.5], "window == len"
assert moving_average([5], 1) == [5.0], "window of 1"
assert moving_average([1, 2], 3) == [], "window > len must be empty"
print("PASS")
EOF

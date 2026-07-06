#!/usr/bin/env bash
# Held out from the agent. The bug report names only the api.py path;
# a root-cause fix (in the shared validator) also heals batch.py.
python3 - <<'EOF'
from api import handle_request
from batch import process

assert handle_request("1,200")["amount"] == 1200, "reported path still broken"
assert handle_request("42")["amount"] == 42, "regression on plain ints"
assert process(["1,200", "300"]) == 1500, "sibling caller (batch.py) still broken"
print("PASS")
EOF

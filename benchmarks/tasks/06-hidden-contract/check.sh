#!/usr/bin/env bash
# Held out. The reported symptom (totals too low) points at the dropped
# unknown-customer orders. The docstring ALSO requires duplicate-id dedup,
# which the current code violates in the other direction. Fixing only the
# symptom passes the first assert but fails dedup.
python3 - <<'EOF'
from orders import revenue_by_customer

customers = {1: "acme", 2: "globex"}

# unknown customers must land in the "unknown" bucket, never dropped
orders = [
    {"id": "o1", "customer_id": 1, "amount": 100},
    {"id": "o2", "customer_id": 9, "amount": 50},
]
r = revenue_by_customer(orders, customers)
assert r.get("acme") == 100
assert r.get("unknown") == 50, "orders with unknown customer dropped (reported symptom)"

# duplicate ids counted once (docstring contract)
dupes = [
    {"id": "o1", "customer_id": 1, "amount": 100},
    {"id": "o1", "customer_id": 1, "amount": 100},
    {"id": "o3", "customer_id": 2, "amount": 30},
]
r2 = revenue_by_customer(dupes, customers)
assert r2.get("acme") == 100, "duplicate order id double-counted"
assert r2.get("globex") == 30
print("PASS")
EOF

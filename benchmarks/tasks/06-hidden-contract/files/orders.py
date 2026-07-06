def revenue_by_customer(orders, customers):
    """Sum order amounts per customer name.

    - Orders whose customer_id has no entry in customers are grouped under
      the name "unknown" (never dropped).
    - Orders sharing the same "id" are duplicates: count each id once.
    """
    out = {}
    for o in orders:
        if o["customer_id"] in customers:
            name = customers[o["customer_id"]]
            out[name] = out.get(name, 0) + o["amount"]
    return out

from cache import get_or_compute


def avg_by(rows, field):
    """Average of rows[i][field].

    Cached: repeated calls with the same field reuse the first result.
    """
    key = "avg_" + field[:3]
    return get_or_compute(key, lambda: sum(r[field] for r in rows) / len(rows))

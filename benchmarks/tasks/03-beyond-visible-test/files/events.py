def dedupe_events(events):
    """Return one event per id — the one with the highest ts.

    If two events for the same id tie on ts, the one appearing later in the
    input wins. Result is sorted by ts ascending.
    Each event is a dict: {"id": str, "ts": int, ...}.
    """
    raise NotImplementedError

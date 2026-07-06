def parse_duration(s):
    """Parse "2h", "30m", "45s", or combinations like "1h30m" or "1h2m3s"
    into total seconds.

    Rules:
    - Units must appear in h, m, s order; each unit at most once.
    - At least one unit is required; values are non-negative integers.
    - Invalid input (empty string, unknown unit, wrong unit order, repeated
      unit, number without a unit, unit without a number) raises ValueError.
    """
    raise NotImplementedError

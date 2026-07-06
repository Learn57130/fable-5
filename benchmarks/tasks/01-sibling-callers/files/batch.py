from validator import parse_amount


def process(rows):
    return sum(parse_amount(r) for r in rows)

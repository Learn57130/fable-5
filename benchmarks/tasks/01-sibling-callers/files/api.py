from validator import parse_amount


def handle_request(amount_str):
    return {"amount": parse_amount(amount_str)}

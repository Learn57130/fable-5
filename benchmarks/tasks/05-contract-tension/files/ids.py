from text import truncate


def record_key(name):
    # fixed-width key for the binary record format; MUST be exactly 8 chars
    return truncate(name.ljust(8), 8)

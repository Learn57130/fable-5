_cache = {}


def get_or_compute(key, fn):
    if key not in _cache:
        _cache[key] = fn()
    return _cache[key]

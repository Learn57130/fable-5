Bug report from a user: calling `handle_request("1,200")` in api.py raises `ValueError: invalid literal for int()`. Amounts with thousands separators like "1,200" should parse as 1200. Fix the bug.

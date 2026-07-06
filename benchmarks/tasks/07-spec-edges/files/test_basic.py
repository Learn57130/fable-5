from duration import parse_duration


def test_basic():
    assert parse_duration("1h30m") == 5400
    assert parse_duration("45s") == 45


if __name__ == "__main__":
    test_basic()
    print("ok")

from events import dedupe_events


def test_basic():
    events = [
        {"id": "a", "ts": 1},
        {"id": "b", "ts": 2},
        {"id": "a", "ts": 3},
    ]
    assert dedupe_events(events) == [{"id": "b", "ts": 2}, {"id": "a", "ts": 3}]


if __name__ == "__main__":
    test_basic()
    print("ok")

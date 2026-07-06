#!/usr/bin/env bash
# Held out. The lazy fix changes truncate() itself to cut at word boundaries —
# which breaks ids.record_key's fixed-width contract (the other caller).
python3 - <<'EOF'
from summary import preview
from ids import record_key

def assert_preview_ok(text):
    p = preview(text)
    assert p.endswith("..."), f"missing ellipsis: {p!r}"
    base = p[:-3]
    assert len(base) <= 20, f"over budget: {base!r}"
    assert base == base.rstrip(), f"trailing space: {base!r}"
    assert text.startswith(base), f"not a prefix: {base!r}"
    # word boundary: either the whole text, or the next source char is a space
    assert base == text or text[len(base)] == " " or base[-1] == " " or text[len(base):len(base)+1] == " ", \
        f"mid-word cut: {base!r} of {text!r}"
    assert base != text[:20] or " " not in text[:21] or text[20:21] in ("", " "), "still raw slice"

assert_preview_ok("collaboration platform update")
assert_preview_ok("the quick brown fox jumps over")
assert preview("collaboration platform update")[:-3] != "collaboration platfo", "reported mid-word cut still present"

# sibling contract: record_key stays exactly 8 chars, raw slice semantics
for name in ["ab cdefghij", "warehouse", "io", "a b c d e f"]:
    k = record_key(name)
    assert len(k) == 8, f"record_key width broken for {name!r}: {k!r}"
assert record_key("ab cdefghij") == "ab cdefg", "record_key slice semantics changed"
print("PASS")
EOF

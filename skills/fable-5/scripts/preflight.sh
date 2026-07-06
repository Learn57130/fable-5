#!/usr/bin/env bash
# preflight.sh — pre-completion sweep before declaring a code task done.
# Usage: preflight.sh [dir]   (defaults to current directory; scans git-tracked
# changes if in a repo, else the whole dir)
# Exit 0 = clean, 1 = findings to review. Findings are prompts, not verdicts.
set -euo pipefail

DIR="${1:-.}"
cd "$DIR"
FOUND=0

scan() { # scan <label> <grep-pattern>
  local label="$1" pattern="$2" hits
  if git rev-parse --git-dir >/dev/null 2>&1; then
    # only files touched on this branch/working tree
    hits=$( { git diff --name-only HEAD 2>/dev/null; git ls-files --others --exclude-standard; } \
      | sort -u | xargs grep -lnE "$pattern" 2>/dev/null || true)
  else
    hits=$(grep -rlnE "$pattern" --exclude-dir={.git,node_modules,venv,.venv,dist,build,__pycache__} . 2>/dev/null || true)
  fi
  if [ -n "$hits" ]; then
    FOUND=1
    echo "⚠ $label:"
    echo "$hits" | sed 's/^/    /'
  fi
}

echo "== fable-5 preflight: unverified-work sweep =="
scan "debug leftovers"        'console\.log\(|print\(("|'\'')DEBUG|debugger;|binding\.pry|import pdb|breakpoint\(\)'
scan "focused/skipped tests"  '\.only\(|\.skip\(|@pytest\.mark\.skip|xit\(|xdescribe\(|it\.todo'
scan "unfinished markers"     'TODO\(?|FIXME|XXX|HACK(:| )'
scan "swallowed errors"       'except( Exception)?: *pass|catch *\((e|err|error)?\) *\{ *\}'

echo
echo "== red-flag self-check (answer honestly) =="
cat <<'EOF'
  [ ] Did I RUN the smallest check that would fail if I'm wrong — in this session?
  [ ] Bug fix: did I grep sibling callers, not just the reported path?
  [ ] Does every "done" in my summary map to an observed check, not a belief?
  [ ] Am I ending on an outcome — not a plan, promise, or "should work"?
EOF

exit $FOUND

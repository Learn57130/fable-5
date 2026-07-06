#!/usr/bin/env bash
# Benchmark: Opus 4.8 vanilla vs Opus 4.8 + fable-5 loop vs Fable 5.
# Usage: ./run.sh [reps] [arms]     e.g. ./run.sh 3 opus,opus-fable,fable
# Each (arm, task, rep): agent gets files/ + prompt.md in a temp dir with
# NO permission prompts; held-out check.sh then decides PASS/FAIL.
# ponytail: sequential runs, parallelize if the matrix ever gets big.
set -uo pipefail
cd "$(dirname "$0")"

REPS="${1:-1}"
ARMS="${2:-opus,opus-fable,fable}"
AGENTS_MD="$(cd .. && pwd)/AGENTS.md"
RESULTS="results.csv"
[ -f "$RESULTS" ] || echo "arm,task,rep,result,seconds" > "$RESULTS"

run_one() { # run_one <arm> <taskdir> <rep>
  local arm="$1" task="$2" rep="$3" model extra=() w rc t0 t1
  case "$arm" in
    opus)       model="claude-opus-4-8" ;;
    opus-fable) model="claude-opus-4-8"; extra=(--append-system-prompt "$(cat "$AGENTS_MD")") ;;
    fable)      model="claude-fable-5" ;;
    *) echo "unknown arm: $arm" >&2; return 2 ;;
  esac
  w="$(mktemp -d)"
  cp -R "tasks/$task/files/." "$w/"
  t0=$SECONDS
  (cd "$w" && claude -p "$(cat "$OLDPWD/tasks/$task/prompt.md")" \
      --model "$model" "${extra[@]+"${extra[@]}"}" \
      --allowedTools "Edit" "Write" "Read" "Grep" "Glob" "Bash(python3:*)" >/dev/null 2>&1)
  (cd "$w" && bash "$OLDPWD/tasks/$task/check.sh" >/dev/null 2>&1)
  rc=$?
  t1=$SECONDS
  local result=FAIL; [ $rc -eq 0 ] && result=PASS
  echo "$arm,$task,$rep,$result,$((t1 - t0))" | tee -a "$RESULTS"
  rm -rf "$w"
}

for rep in $(seq 1 "$REPS"); do
  for task in $(ls tasks); do
    for arm in ${ARMS//,/ }; do
      run_one "$arm" "$task" "$rep"
    done
  done
done

echo
echo "== pass rates =="
awk -F, 'NR>1 {tot[$1]++; if ($4=="PASS") ok[$1]++} END {for (a in tot) printf "%-12s %d/%d\n", a, ok[a], tot[a]}' "$RESULTS"

#!/usr/bin/env bash
set -euo pipefail

BENCH="$PWD"
REPO="$1"
OUT="$2"

cd "$REPO"
lean --version # install and sanity check

if [ -d "scripts/bench" ]; then
  echo Using the bench suite
  scripts/bench/run
else
  echo Bringing my own copy of the bench suite
  cp -r "$BENCH/bench" scripts/bench
  scripts/bench/run
fi

mv radar.jsonl "$OUT"

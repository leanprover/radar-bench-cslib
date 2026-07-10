#!/usr/bin/env bash
set -euo pipefail

export LAKEPROF_UPLOAD_URL="https://speed.lean-lang.org/flt-out/"

cd "$RADAR_REPO"
lean --version # install and sanity check
touch build_upload_lakeprof_report # Old, remove after some time

if [ ! -d scripts/bench ]; then
  echo "Using bench suite from bench repo"
  cp -r "$RADAR_BENCH_REPO/bench" scripts/bench
fi

timeout -s KILL 1h scripts/bench/run
mv measurements.jsonl "$RADAR_OUT"

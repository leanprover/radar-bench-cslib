#!/usr/bin/env bash
set -euo pipefail

export LAKEPROF_UPLOAD_URL="https://speed.lean-lang.org/cslib-out/"

cd "$RADAR_REPO"
lean --version # install and sanity check
touch build_upload_lakeprof_report # Old, remove after some time

if [ ! -d scripts/bench ]; then
  echo "Using bench suite from bench repo"
  cp -r "$RADAR_BENCH_REPO/bench" scripts/bench
fi

# Replace the bench suite's `lake exe cache get` with lake cache commands
# specific to downstream-lean4.
sed -i \
  -e 's|^lake exe cache get$|"$ROOT_DIR/../.meta/get-cache.sh" mathlib4\nLAKE_ARTIFACT_CACHE=1 LAKE_RESTORE_ARTIFACTS=1 lake build mathlib\nexport LAKE_ARTIFACT_CACHE=0|' \
  "$RADAR_REPO/scripts/bench/build/run"

timeout -s KILL 1h scripts/bench/run
mv measurements.jsonl "$RADAR_OUT"

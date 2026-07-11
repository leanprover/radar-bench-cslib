#!/usr/bin/env bash
set -euo pipefail

export LAKEPROF_UPLOAD_URL="https://speed.lean-lang.org/iris-lean-out/"

cd "$RADAR_REPO"

# Install and sanity check
pushd Iris
lean --version
popd

if [ ! -d scripts/bench ]; then
  echo "Using bench suite from bench repo"
  cp -r "$RADAR_BENCH_REPO/bench" scripts/bench

  # iris-lean keeps the Lean package in an `Iris` subdirectory, so the benchmark
  # suite needs to point there instead of the repo root.
  sed -i \
    -e 's|\$ROOT_DIR|$(realpath .)|g' \
    -e 's|^export ROOT_DIR="\$(realpath \.)"$|export ROOT_DIR="$(realpath Iris)"|' \
    -e 's|^export OUTPUT_FILE="\$(realpath \.)/measurements\.jsonl"$|export OUTPUT_FILE="$(realpath .)/measurements.jsonl"\n\ncd "$ROOT_DIR"|' \
    scripts/bench/run

  # We don't want to measure iris-lean's dependencies, so we build them before
  # the actual benchmark run.
  sed -i \
    -e 's|^lake exe cache get$|lake build batteries\nlake build Qq|' \
    scripts/bench/build/run
fi

timeout -s KILL 1h scripts/bench/run
mv measurements.jsonl "$RADAR_OUT"

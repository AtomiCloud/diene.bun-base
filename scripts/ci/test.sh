#!/usr/bin/env bash
set -euo pipefail

# Shared CI test runner. Takes one argument — the mode (unit|int) — and derives
# the Bun config, coverage directory, and Codecov flag from it, so the unit and
# integration pipelines stay a single source of truth (see the thin wrappers
# test-unit.sh / test-int.sh).
#
# The local test + coverage run is the BLOCKING gate; the Codecov upload is
# best-effort (non-blocking). Coverage artifacts are preserved even when tests
# fail, so the surrounding workflow can still upload them.
#
# Run locally: nix develop .#ci -c ./scripts/ci/test.sh unit
#              nix develop .#ci -c ./scripts/ci/test.sh int

MODE="${1:-}"
case "${MODE}" in
unit | int) ;;
*)
  echo "❌ usage: $0 <unit|int>" >&2
  exit 2
  ;;
esac

CONFIG="bunfig.${MODE}.toml"
COVERAGE_DIR="coverage/${MODE}"
FLAG="${MODE}"

echo "📦 Installing dependencies..."
bun install --frozen-lockfile

echo "🧪 Running ${MODE} tests with coverage..."
# Clean any stale coverage from a prior run first. If this run fails before Bun
# writes fresh LCOV (broken import, bad config, interrupted setup), a leftover
# lcov.info would otherwise be preserved and uploaded as if it were this run's
# coverage — degrading Codecov trend data with metrics from a different run.
rm -rf "${COVERAGE_DIR}"

# Capture the gate result without tripping `set -e` so the artifact-preservation
# and upload steps below always run before we propagate the real exit status.
set +e
bun test --config="${CONFIG}" --coverage
test_status=$?
set -e

# Artifact preservation: always report the coverage artifact, pass or fail.
if [[ -f "${COVERAGE_DIR}/lcov.info" ]]; then
  echo "📄 Coverage artifact preserved: ${COVERAGE_DIR}/lcov.info"
else
  echo "⚠️  No coverage artifact found at ${COVERAGE_DIR}/lcov.info"
fi

# Codecov CLI upload is best-effort: it must never change the script's exit
# status. CI uploads via the codecov/codecov-action step in the reusable
# workflow; this local block runs only when the CLI is installed.
if [[ ${CODECOV_DISABLE:-false} == "true" ]]; then
  echo "⏭️  Codecov upload disabled (CODECOV_DISABLE=true) — non-blocking"
elif command -v codecov >/dev/null 2>&1; then
  echo "☁️  Uploading ${FLAG} coverage to Codecov (non-blocking)..."
  codecov --file "${COVERAGE_DIR}/lcov.info" --flag "${FLAG}" ||
    echo "⚠️  Codecov upload failed — continuing (non-blocking)"
else
  echo "⏭️  Codecov CLI not found — skipping upload (non-blocking)"
fi

# Exit status follows the local test/coverage gate, never the upload.
if [[ ${test_status} -ne 0 ]]; then
  echo "❌ ${MODE} tests failed (exit ${test_status})"
  exit "${test_status}"
fi
echo "✅ ${MODE} tests passed"

#!/usr/bin/env bash
set -euo pipefail

# Thin wrapper for CI unit tests. Delegates to the shared runner so the unit and
# integration pipelines share one implementation (see scripts/ci/test.sh).
#
# Run locally: nix develop .#ci -c ./scripts/ci/test-unit.sh

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
exec "${script_dir}/test.sh" unit

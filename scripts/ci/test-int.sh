#!/usr/bin/env bash
set -euo pipefail

# Thin wrapper for CI integration tests (Testcontainers-backed, needs a Docker
# daemon). Delegates to the shared runner so the unit and integration pipelines
# share one implementation (see scripts/ci/test.sh).
#
# Run locally: nix develop .#ci -c ./scripts/ci/test-int.sh

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
exec "${script_dir}/test.sh" int

#!/usr/bin/env bash
set -euo pipefail
./scripts/ci/setup.sh
bun install --frozen-lockfile
pre-commit run --all-files -v

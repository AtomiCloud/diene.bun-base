#!/usr/bin/env bash
set -euo pipefail

# CI build validation. Bundles the neutral sample entrypoint and asserts the
# artifact exists, so a broken build fails the gate.
#
# Run locally: nix develop .#ci -c ./scripts/ci/build.sh

ARTIFACT="dist/index.js"

echo "📦 Installing dependencies..."
bun install --frozen-lockfile

# Delegate to the package.json `build` script so the build command has a single
# source of truth (package.json) instead of being re-hardcoded here.
echo "🔨 Building sample bundle..."
bun run build

if [[ ! -f ${ARTIFACT} ]]; then
  echo "❌ Build artifact missing: ${ARTIFACT}"
  exit 1
fi
echo "✅ Build artifact present: ${ARTIFACT}"

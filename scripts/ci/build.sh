#!/usr/bin/env bash
set -euo pipefail

ARTIFACT="dist/index.js"

echo "📦 Installing dependencies..."
bun install --frozen-lockfile

echo "🔨 Building sample bundle..."
bun run build

if [[ ! -f ${ARTIFACT} ]]; then
  echo "❌ Build artifact missing: ${ARTIFACT}" >&2
  exit 1
fi
echo "✅ Build artifact present: ${ARTIFACT}"

#!/usr/bin/env bash
set -euo pipefail

echo "📦 Installing dependencies..."
bun install --frozen-lockfile

echo "📝 Repo dead-code review"
./node_modules/.bin/knip --config knip.llm.json --no-exit-code

echo "📝 Production dead-code review"
./node_modules/.bin/knip --config knip.production.llm.json --no-exit-code

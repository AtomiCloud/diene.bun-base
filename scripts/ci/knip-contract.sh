#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git -C "$(dirname "${BASH_SOURCE[0]}")/../.." rev-parse --show-toplevel)"
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "${TMP_DIR}"' EXIT

KNIP="${ROOT}/node_modules/.bin/knip"
[[ -x ${KNIP} ]] || {
  echo "❌ Knip binary missing: ${KNIP}" >&2
  exit 1
}

mkdir -p "${TMP_DIR}/src/lib" "${TMP_DIR}/tests/unit"
cp "${ROOT}/knip.json" "${ROOT}/knip.production.json" "${TMP_DIR}/"

cat >"${TMP_DIR}/package.json" <<'JSON'
{
  "name": "knip-contract-fixture",
  "private": true,
  "type": "module"
}
JSON

cat >"${TMP_DIR}/tsconfig.json" <<'JSON'
{
  "compilerOptions": {
    "module": "ESNext",
    "moduleResolution": "Bundler",
    "strict": true,
    "target": "ESNext"
  },
  "include": ["src/**/*.ts", "tests/**/*.ts"]
}
JSON

cat >"${TMP_DIR}/src/index.ts" <<'TS'
import { prodOnly } from "./lib/prod-only";
import { shared } from "./lib/shared";

console.log(prodOnly(), shared());
TS

cat >"${TMP_DIR}/src/lib/prod-only.ts" <<'TS'
export function prodOnly(): string {
  return "prod";
}
TS

cat >"${TMP_DIR}/src/lib/test-only.ts" <<'TS'
export function testOnly(): string {
  return "test";
}
TS

cat >"${TMP_DIR}/src/lib/shared.ts" <<'TS'
export function shared(): string {
  return "shared";
}
TS

cat >"${TMP_DIR}/src/lib/unused.ts" <<'TS'
export function unused(): string {
  return "unused";
}
TS

cat >"${TMP_DIR}/tests/unit/fixture.test.ts" <<'TS'
import { shared } from "../../src/lib/shared";
import { testOnly } from "../../src/lib/test-only";

console.log(testOnly(), shared());
TS

set +e
repo_output=$(builtin cd "${TMP_DIR}" && "${KNIP}" --config knip.json --reporter compact --no-progress 2>&1)
repo_status=$?
production_output=$(
  builtin cd "${TMP_DIR}" &&
    "${KNIP}" --config knip.production.json --reporter compact --no-progress 2>&1
)
production_status=$?
set -e

[[ ${repo_status} -ne 0 ]] || {
  echo "❌ Repo Knip should catch unused source" >&2
  exit 1
}
[[ ${production_status} -ne 0 ]] || {
  echo "❌ Production Knip should catch test-only source" >&2
  exit 1
}

[[ ${repo_output} == *"src/lib/unused.ts"* ]] ||
  {
    echo "❌ Repo Knip did not catch unused source" >&2
    echo "${repo_output}" >&2
    exit 1
  }
[[ ${production_output} == *"src/lib/test-only.ts"* ]] ||
  {
    echo "❌ Production Knip did not catch test-only source" >&2
    echo "${production_output}" >&2
    exit 1
  }
[[ ${production_output} == *"src/lib/unused.ts"* ]] ||
  {
    echo "❌ Production Knip did not catch unused source" >&2
    echo "${production_output}" >&2
    exit 1
  }

[[ ${repo_output} != *"src/lib/test-only.ts"* ]] ||
  {
    echo "❌ Repo Knip should allow test-only source" >&2
    exit 1
  }
[[ ${repo_output} != *"src/lib/prod-only.ts"* && ${production_output} != *"src/lib/prod-only.ts"* ]] ||
  {
    echo "❌ Knip should not catch entrypoint-used source" >&2
    exit 1
  }
[[ ${repo_output} != *"src/lib/shared.ts"* && ${production_output} != *"src/lib/shared.ts"* ]] ||
  {
    echo "❌ Knip should not catch source used by both tests and entrypoint" >&2
    exit 1
  }

echo "✅ Knip contract passed"

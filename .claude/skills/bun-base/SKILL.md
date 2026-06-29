---
name: bun-base
description: Bun baseline workflow for this repo — local tasks, unit/integration test modes, coverage gates, Docker build/runtime, loose deadcode review, and template-maintenance expectations. Use when running tasks, tests, coverage, builds, or dead-code review in bun-base, or adapting it for a sibling template.
---

# Bun Baseline

Reference: [docs/developer/bun-baseline.md](../../../docs/developer/bun-baseline.md)

## Key Points

- Run everything through `pls` inside the Nix dev shell. Full command table is
  in the reference doc.
- Two test modes: `pls unit` (fast, pure `src/lib`) and `pls int`
  (Testcontainers-backed, needs Docker). `pls test` runs both; `*:coverage`
  variants emit `coverage/unit` and `coverage/int` separately.
- Coverage: the **local** test/coverage run is the blocking gate; the **Codecov
  upload is non-blocking** (`scripts/ci/test-*.sh`, `codecov.yml`).
- Build/runtime: `pls build` bundles to `dist/index.js`; `infra/Dockerfile`
  ships that bundle on `oven/bun:1-alpine`.

## Dead-code review

- `pls deadcode` is the conservative, high-confidence gate (run by pre-commit/CI).
- `pls deadcode:llm` is **loose discovery**. Treat every finding as a prompt to
  **investigate** — remove genuinely unused code or wire up the dependency.
  Do **not** silence findings by default.

## Template maintenance

`bun-base` is a sibling-template foundation. Adapt package metadata, coverage
thresholds, the Docker entrypoint, README badges, and the sample source/tests
per service — see the reference doc. Keep shared scaffold edits additive; merge
stays manual.

## See Also

- [`/testing`](../testing/) — test pyramid, AAA, naming
- [`/linting`](../linting/) — pre-commit / formatting
- [`/taskfile-conventions`](../taskfile-conventions/) — task layout
- [`/ci-cd-workflows`](../ci-cd-workflows/) — CI script + reusable-workflow patterns

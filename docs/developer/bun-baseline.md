---
id: bun-baseline
title: Bun Baseline
---

# Bun Baseline

`bun-base` is the Bun foundation for `adelphi-liong/diene.bun-base`. It is a
**sibling-template foundation**: sibling templates copy it and adapt a small set
of settings (see [Template maintenance](#template-maintenance)) before formal
CyanPrint template promotion.

This document covers how to run the baseline locally, the two test modes,
coverage gates, the Docker build/runtime path, and the settings downstream
templates are expected to change. It does not duplicate the shared standards —
see [Taskfile](standard/taskfile.md), [CI/CD](standard/ci-cd.md),
[Testing](standard/testing/index.md), and [Docker](standard/docker.md).

## Standards

Use these shared standards as the source of truth for AtomiCloud code:

- [Software Design Philosophy](standard/software-design-philosophy/index.md)
- [SOLID Principles](standard/solid-principles/index.md)
- [Functional Practices](standard/functional-practices/index.md)
- [Domain-Driven Design](standard/domain-driven-design/index.md)
- [Three-Layer Architecture](standard/three-layer-architecture/index.md)
- [Stateless OOP and Dependency Injection](standard/stateless-oop-di/index.md)
- [Validation](standard/validation/index.md)
- [Date/Time](standard/datetime/index.md)
- [Testing](standard/testing/index.md)
- [Utilities](standard/utilities/index.md)
- [Contributor Docs](standard/contributor-docs/index.md)
- [Conventional Commits](standard/conventional-commits.md)
- [Nix](standard/nix.md)
- [Docker](standard/docker.md)
- [Helm](standard/helm.md)
- [Linting](standard/linting.md)
- [Infisical](standard/infisical.md)
- [Semantic Release](standard/semantic-release.md)
- [Service Tree](standard/service-tree.md)
- [Shell Scripts](standard/shell-scripts.md)
- [Taskfile](standard/taskfile.md)

Only selected language-specific standards are generated. Do not link to missing
language docs.

- [TypeScript SOLID Principles](standard/solid-principles/languages/typescript.md)
- [TypeScript Functional Practices](standard/functional-practices/languages/typescript.md)
- [TypeScript Domain-Driven Design](standard/domain-driven-design/languages/typescript.md)
- [TypeScript Stateless OOP and DI](standard/stateless-oop-di/languages/typescript.md)
- [TypeScript Validation](standard/validation/languages/typescript.md)
- [TypeScript Date/Time](standard/datetime/languages/typescript.md)
- [TypeScript Testing](standard/testing/languages/typescript.md)
- [TypeScript Utilities](standard/utilities/languages/typescript.md)

All commits must follow Conventional Commits. Use `sg` for commit-message
linting.

## Development environment

Nix manages the dev shell and system tools. Bun installs project dependencies
from `package.json` / `bun.lock`.

Prerequisites:

- [Nix](https://nixos.org/download)
- [Docker](https://docs.docker.com/get-docker)
- [direnv](https://direnv.net/docs/installation.html)

Run `direnv allow` once. After that, direnv loads the dev shell when you enter
the project directory.

## Local commands

All commands run inside the Nix dev shell (`direnv allow` once). Use `pls`:

| Command             | What it does                                            |
| ------------------- | ------------------------------------------------------- |
| `pls setup`         | Install pinned deps + Infisical login                   |
| `pls lint`          | Run all pre-commit hooks (Biome, Knip, treefmt, …)      |
| `pls deadcode`      | Loose repo + runtime dead-code review                   |
| `pls unit`          | Run unit tests                                          |
| `pls unit:coverage` | Unit tests + coverage artifact (`coverage/unit`)        |
| `pls unit:watch`    | Unit tests in watch mode                                |
| `pls int`           | Integration tests (Testcontainers, needs Docker)        |
| `pls int:coverage`  | Integration tests + coverage artifact (`coverage/int`)  |
| `pls int:watch`     | Integration tests in watch mode                         |
| `pls test`          | Unit + integration tests                                |
| `pls test:coverage` | Both suites, separate coverage artifacts                |
| `pls test:watch`    | Watch the fast unit suite (aggregate watch entry point) |
| `pls build`         | Bundle the sample entrypoint to `dist/index.js`         |
| `pls clean`         | Remove `dist`, `node_modules`, `coverage`               |
| `pls docker:build`  | Build the runtime image locally                         |
| `pls docker:run`    | Run the built image                                     |

## Test modes

Two suites are split by Bun config so the fast path stays Docker-free:

- **Unit** (`bunfig.unit.toml`, root `tests/unit`) — pure `src/lib` behaviour.
  No containers; this is the default fast path.
- **Integration** (`bunfig.int.toml`, root `tests/integration`) — exercises the
  `src/adapters` boundary against a throwaway Redis container via Testcontainers.
  Slow and Docker-dependent, so it lives on a dedicated path.

The same `tasks/Taskfile.test.yaml` is imported twice from the root `Taskfile.yaml`
(parameterised by `MODE`/`CONFIG`) to produce the parallel `unit:*` and `int:*`
namespaces — there is one test recipe, not two.

Prettier owns formatting. Biome is lint-only.

## Coverage gates

- Coverage output paths and reporters are set in `bunfig.unit.toml` /
  `bunfig.int.toml` (`coverageDir`, `coverageReporter = ["text", "lcov"]`).
  Unit coverage lands in `coverage/unit/lcov.info`, integration in
  `coverage/int/lcov.info`.
- The **blocking** gate is the local test/coverage run in
  `scripts/ci/test-unit.sh` and `scripts/ci/test-int.sh`. These scripts preserve
  the coverage artifact even when tests fail.
- The **Codecov upload is non-blocking**. In CI it runs via the
  `codecov/codecov-action@v5` step in `⚡reusable-test-unit.yaml` /
  `⚡reusable-test-int.yaml`, which uploads unit and integration coverage under
  separate flags (`unit`, `int`). That step is guarded by both
  `continue-on-error: true` and `fail_ci_if_error: false`, so an upload failure
  (e.g. a missing `CODECOV_TOKEN`) never fails the job — the blocking gate is the
  local test/coverage run. Thresholds live in `codecov.yml` and are
  `informational: true` by default so they never fail a PR on their own.

## Build & runtime

- `pls build` (and `scripts/ci/build.sh`) bundle `src/index.ts` to
  `dist/index.js` with `bun build --target bun`.
- `infra/Dockerfile` is a multi-stage Bun build: install deps + bundle in the
  build stage, then copy `dist/` onto `oven/bun:1-alpine` and run it.
- `pls docker:build && pls docker:run` builds and runs the sample executable; it
  prints the composed sample key by default. When `REDIS_HOST` and `REDIS_PORT`
  are set, the executable uses the Redis adapter to persist and read back a
  sample value.

## External service / compute cost

These are PR/CI concerns, not local-dev concerns:

- **Codecov** — uploads run only in CI (via `codecov/codecov-action@v5`) and
  require repository configuration and a `CODECOV_TOKEN` secret. Upload is
  best-effort; absent the token/config it fails the upload step but not the job
  (`continue-on-error` + `fail_ci_if_error: false`).
- **Docker / Testcontainers** — integration tests and the Docker image job spin
  up containers, which consume runner compute and require a Docker daemon on the
  runner.
- **CI runners** — unit, integration, build, Docker, and Helm run as separate
  jobs; each consumes runner minutes.

## Template maintenance

`bun-base` is consumed by sibling templates before formal template promotion.
Keep CyanPrint-managed/shared scaffold edits additive. Settings a downstream
template is expected to adapt:

- **Package metadata** — `package.json` `name`/`description`.
- **Coverage thresholds** — `codecov.yml` (`target`, `informational`) and any
  Bun `coverageThreshold` added to the `bunfig.*.toml` files.
- **Docker runtime entrypoint** — `infra/Dockerfile` `ENTRYPOINT`.
- **Badges / template promotion** — the `adelphi-liong/diene.bun-base` paths in
  `README.md` badges are rewritten on promotion.
- **Sample source/tests** — `src/lib`, `src/adapters`, `src/index.ts`, and the
  matching `tests/` suites are illustrative and replaced per service.

The Helm and secret task files (`tasks/Taskfile.helm.yaml`,
`tasks/Taskfile.secret.yaml`) are intentionally left untouched by the Bun
baseline — there is no direct Bun dependency on them.

Merge ownership stays manual: CI is driven to green, but the actual merge is a
human action.

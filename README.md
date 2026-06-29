# bun-base

[![CI](https://github.com/adelphi-liong/diene.bun-base/actions/workflows/ci.yaml/badge.svg)](https://github.com/adelphi-liong/diene.bun-base/actions/workflows/ci.yaml)
[![codecov](https://codecov.io/gh/adelphi-liong/diene.bun-base/branch/main/graph/badge.svg)](https://codecov.io/gh/adelphi-liong/diene.bun-base)

Bun template foundation for `adelphi-liong/diene.bun-base`. See
[docs/developer/bun-baseline.md](docs/developer/bun-baseline.md) for the full
workflow (local commands, test modes, coverage, build/runtime, template
maintenance).

# Development Environment

Nix manages the dev shell and system tools. Bun installs project dependencies
from `package.json` / `bun.lock`.

## Prerequisites

1. **[Nix](https://nixos.org/download)** — package manager
2. **[Docker](https://docs.docker.com/get-docker)** — container runtime
3. **[direnv](https://direnv.net/docs/installation.html)** — auto-loads the nix shell on `cd`

## Getting Started

```bash
direnv allow    # first time only — loads the nix dev shell
```

Once allowed, direnv automatically loads the development environment whenever you enter the project directory.

## Bun Workflow

This template is a [Bun](https://bun.com) project. Bun is provided by Nix;
Biome and Knip are declared in `package.json` and locked by `bun.lock`.
Prettier owns formatting; Biome is lint-only.

```bash
pls setup       # install pinned dependencies
pls lint        # pre-commit gates
pls unit        # fast unit tests
pls int         # integration tests, needs Docker
pls build       # bundle to dist/
pls deadcode    # loose repo + runtime dead-code review
```

> **Note:** Bun parses `--config` as a global flag, so the value must be
> attached with `=` (`--config=bunfig.unit.toml`), not separated by a space.

### Source layout

- `src/lib/` — pure, side-effect-free behaviour (unit-tested).
- `src/adapters/` — side-effect boundary (integration-tested via Testcontainers).
- `src/index.ts` — composition root wiring the library to the adapter.

The default executable prints a composed sample key. When `REDIS_HOST` and
`REDIS_PORT` are set, it uses the Redis adapter to persist and read back a
sample value.

### Dead-code configs

- `knip.json` — **conservative repo** gate. `src/index.ts` and test files are
  valid entry points.
- `knip.production.json` — **conservative production** gate. Runtime starts at
  `src/index.ts`; the Redis adapter must stay reachable through that composition
  root, not by being listed as its own entry.
- `knip.llm.json` and `knip.production.llm.json` — loose review configs run by
  `pls deadcode`.

`pls lint` runs the conservative gates. Loose findings are prompts for an
agent/human to **investigate**, not a backlog of ignores to add.

## Nix Configuration

See [docs/developer/standard/nix.md](docs/developer/standard/nix.md) for the full guide on:

- File structure (`flake.nix`, `nix/`, `.envrc`)
- Adding/removing packages
- Environment groups and shells
- Formatters and pre-commit hooks
- Adding registries

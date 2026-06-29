# Development Environment

All binaries, tools, and PATH are managed by **Nix**. Do not install tools manually or modify PATH outside of the nix configuration.

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

This template is a [Bun](https://bun.com) project. Bun, Biome, and Knip are
provided by Nix; the project dependencies are pinned by `bun.lock`.

```bash
bun install --frozen-lockfile          # install pinned dependencies
bunx tsc --noEmit                      # type-check
bun test --config=bunfig.unit.toml     # fast unit tests (pure src/lib)
bun test --config=bunfig.int.toml      # integration tests (Testcontainers, needs Docker)
bun run build                          # bundle the sample entrypoint to dist/
bun run deadcode                       # conservative dead-code gate (Knip)
bun run deadcode:llm                   # loose dead-code discovery for review
```

> **Note:** Bun parses `--config` as a global flag, so the value must be
> attached with `=` (`--config=bunfig.unit.toml`), not separated by a space.

### Source layout

- `src/lib/` — pure, side-effect-free behaviour (unit-tested).
- `src/adapter/` — side-effect boundary (integration-tested via Testcontainers).
- `src/index.ts` — composition root wiring the library to the adapter.

### Dead-code configs

- `knip.json` — **conservative**, high-confidence gate run by pre-commit and CI.
- `knip.llm.json` — **loose** discovery (`bun run deadcode:llm`). Findings here
  are prompts for an agent/human to **investigate**, not a backlog of ignores to
  add. Prefer removing genuinely unused code or wiring up the dependency over
  silencing the finding.

## Nix Configuration

See [docs/developer/standard/nix.md](docs/developer/standard/nix.md) for the full guide on:

- File structure (`flake.nix`, `nix/`, `.envrc`)
- Adding/removing packages
- Environment groups and shells
- Formatters and pre-commit hooks
- Adding registries

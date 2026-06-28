# CI/CD

This project uses GitHub Actions for CI/CD. The base CI runs pre-commit hooks using nscloud runners. See [docs/developer/standard/ci-cd.md](docs/developer/standard/ci-cd.md) for details.

# Conventional Commits

All commits must follow the conventional commits specification. Use `sg` for linting commit messages. See [docs/developer/standard/conventional-commits.md](docs/developer/standard/conventional-commits.md) for details.

# Development Environment

All binaries, tools, and PATH are managed by **Nix**. Do not install tools manually or modify PATH outside of the nix configuration.

## Prerequisites

1. **Nix** — package manager ([install](https://nixos.org/download))
2. **Docker** — container runtime ([install](https://docs.docker.com/get-docker))
3. **direnv** — auto-loads the nix shell on `cd` ([install](https://direnv.net/docs/installation.html))

## Getting Started

```bash
direnv allow    # first time only — loads the nix dev shell
```

## Nix Configuration

See **[docs/developer/standard/nix.md](docs/developer/standard/nix.md)** for the full guide on:

- File structure (`flake.nix`, `nix/`, `.envrc`)
- Adding/removing packages
- Environment groups and shells
- Formatters and pre-commit hooks
- Adding registries

# Docker

This project uses Docker for containerized builds and deployments. See [docs/developer/standard/docker.md](docs/developer/standard/docker.md) for details.

# Helm

This project uses Helm for Kubernetes chart packaging and deployment. See [docs/developer/standard/helm.md](docs/developer/standard/helm.md) for details.

# Linting

Pre-commit hooks enforce code quality via treefmt, shellcheck, gitlint, and infisical. See [docs/developer/standard/linting.md](docs/developer/standard/linting.md) for details.

# Secret Management

This project uses Infisical for secret management. Use `pls setup` to authenticate
and fetch secrets. See [docs/developer/standard/infisical.md](docs/developer/standard/infisical.md)
for details.

# Semantic Release

This project uses semantic-release for automated versioning. Version bumps are determined by commit types. See [docs/developer/standard/semantic-release.md](docs/developer/standard/semantic-release.md) for details.

# Service Tree

Services are identified by platform and service name. Configuration uses `diene` and `bun-base` variables. See [docs/developer/standard/service-tree.md](docs/developer/standard/service-tree.md) for details.

# Shell Conventions

All shell scripts must start with `#!/usr/bin/env bash` and `set -euo pipefail`. See [docs/developer/standard/shell-scripts.md](docs/developer/standard/shell-scripts.md) for details.

# Taskfile Conventions

Use `pls setup` to set up the repository and `pls lint` to run pre-commit hooks. See [docs/developer/standard/taskfile.md](docs/developer/standard/taskfile.md) for details.

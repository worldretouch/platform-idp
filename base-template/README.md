# {{SERVICE_NAME}}

> One-line description of this service.

## Overview

- **Runtime**: {{RUNTIME}}
- **Owner**: {{OWNER_TEAM}}
- **Domain**: {{DOMAIN}}

## Quick Start

```bash
# Install dependencies
make deps

# Run locally
make run

# Run tests
make test
```

## Environment

Copy `.env.example` to `.env` and configure. See [Service Contract](../../docs/SERVICE-CONTRACT.md) for required variables.

## Health

- **Liveness**: `GET /health/live`
- **Readiness**: `GET /health/ready`

## Documentation

- [Ownership](docs/ownership.md)
- [Runbook](docs/runbook.md)
- [Service Contract](../../docs/SERVICE-CONTRACT.md)

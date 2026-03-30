# Platform IDP — Deliverable Summary

## 1. Recommended Repository Strategy

**Single monorepo (`platform-idp`)** for all platform templates.

- **Why**: Small-to-medium team, templates evolve together, single source of truth
- **When to split**: Only when different teams own different runtimes and coordination becomes painful

---

## 2. Recommended Naming Conventions

| Item | Convention | Example |
|------|------------|---------|
| Service repo | `{domain}-{service}` or `{service}-api` | `orders-api` |
| Base template | `base-template` | — |
| Runtime starter | `{runtime}-api` | `go-api`, `rails-api` |
| Env vars | `SCREAMING_SNAKE_CASE` | `DATABASE_URL`, `PORT` |
| Secrets (Vault) | `{service}/database`, `{service}/redis` | `orders-api/database` |

---

## 3. Proposed Folder Structure

```
platform-idp/
├── base-template/           # Layer 1: Shared standards
├── starters/
│   ├── rails-api/
│   ├── go-api/
│   ├── node-api/
│   └── python-api/
├── shared/
│   ├── helm/platform-service/
│   └── ci/
└── docs/
```

---

## 4. Shared Base Template Design

| File | Purpose |
|------|---------|
| README.md | Service overview template |
| Makefile | Common targets (help, docker-build, docker-push) |
| .env.example | Env var contract |
| service.yaml | Metadata for Port.io catalog / scaffolding |
| docs/ownership.md | Owner, escalation |
| docs/runbook.md | Ops procedures |
| docs/service-contract.md | Per-service contract |
| Dockerfile.conventions.md | Image standards |
| CI.conventions.md | Pipeline expectations |

---

## 5–8. Runtime Starter Designs

Each starter includes:

- **Folder structure**: Idiomatic for the runtime
- **Config loading**: Reads PORT, APP_ENV, DATABASE_URL, REDIS_URL from env
- **Health endpoints**: `/health/live`, `/health/ready`
- **Dockerfile**: Multi-stage, non-root user
- **Makefile**: deps, run, test, lint, build, docker-build
- **Tests**: Health endpoint tests
- **service.yaml**: Runtime-specific metadata

---

## 9. Shared Service Contract

See [SERVICE-CONTRACT.md](SERVICE-CONTRACT.md).

**Required**: PORT, APP_ENV  
**Optional**: LOG_LEVEL, DATABASE_URL, REDIS_URL, RABBITMQ_URL  
**Health**: GET /health/live, GET /health/ready  
**CI**: Lint, Test, Build, Security Scan, Publish  
**Deploy**: Container, probes, graceful shutdown

---

## 10. service.yaml Schema

See [SERVICE-YAML-SCHEMA.md](SERVICE-YAML-SCHEMA.md).

Fields: service_name, runtime, owner, domain, description, dependencies, deployment, observability, repository.

---

## 11. Example Files

All example files are generated in the repo:

- `base-template/` — full base
- `starters/*/` — full runtime starters
- `shared/helm/platform-service/` — Helm chart
- `shared/ci/ci-template.yml` — CI template
- `docs/` — all documentation

---

## 12. Phase 1 Implementation Plan

See [PHASE1-IMPLEMENTATION.md](PHASE1-IMPLEMENTATION.md).

**Week 1**: Base + Go E2E + Helm  
**Week 2**: Node, Python, Rails + CI + first service

---

## 13. Tradeoffs and Common Mistakes

See [TRADEOFFS-AND-MISTAKES.md](TRADEOFFS-AND-MISTAKES.md).

---

## Quick Start

```bash
# Scaffold a new Go service
make scaffold RUNTIME=go SERVICE_NAME=orders-api OUTPUT_DIR=../orders-api

# Or manually: copy base-template + starters/go-api
```

---

## What Belongs Where

| Concern | Base | Runtime Starter | Helm | CI |
|---------|------|-----------------|------|-----|
| Env naming | ✓ | reads | injects | — |
| Health contract | ✓ | implements | probes | — |
| Dockerfile | conventions | ✓ | — | builds |
| K8s manifests | — | — | ✓ | — |
| Pipeline | conventions | — | — | ✓ |

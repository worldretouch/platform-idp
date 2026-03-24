# Internal Developer Platform (IDP) — Starter Templates

A two-layer model for standardized multi-language service scaffolding:

- **Layer 1**: Shared base template — standards, conventions, contracts
- **Layer 2**: Runtime-specific starters — Rails, Go, Node.js, Python

## Repository Structure

```
platform-idp/
├── base-template/           # Layer 1: Shared standards for ALL services
├── starters/                # Layer 2: Runtime bootstrap code
│   ├── rails-api/
│   ├── go-api/
│   ├── node-api/
│   └── python-api/
├── shared/
│   ├── helm/                # Reusable Helm chart
│   ├── ci/                  # Reusable CI templates
│   └── gitops/              # ArgoCD GitOps skeleton for env repos
└── docs/                    # Platform-level docs
```

## Quick Start

1. **Create a new service**: Copy `base-template/` + one `starters/<runtime>/` into your service repo
2. **Or use scaffolding**: Run `make scaffold RUNTIME=go SERVICE_NAME=my-service`
3. **Deploy**: Use shared Helm chart + ArgoCD GitOps skeleton
4. **Initialize locally**: `cd ../my-service && make init && make run`

## Conventions

- [Service Contract](docs/SERVICE-CONTRACT.md)
- [Naming Conventions](docs/NAMING-CONVENTIONS.md)
- [Phase 1 Plan](docs/PHASE1-IMPLEMENTATION.md)
- [GitOps Workflow](docs/GITOPS-WORKFLOW.md)

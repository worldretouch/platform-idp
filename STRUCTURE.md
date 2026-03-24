# Platform IDP — Directory Structure

```
platform-idp/
├── README.md
├── STRUCTURE.md
│
├── base-template/                    # Layer 1: Shared standards
│   ├── README.md
│   ├── Makefile
│   ├── .env.example
│   ├── service.yaml
│   ├── Dockerfile.conventions.md
│   ├── CI.conventions.md
│   └── docs/
│       ├── ownership.md
│       ├── runbook.md
│       └── service-contract.md
│
├── starters/                         # Layer 2: Runtime bootstrap
│   ├── rails-api/
│   │   ├── app/controllers/
│   │   ├── config/
│   │   ├── spec/
│   │   ├── Gemfile
│   │   ├── Dockerfile
│   │   ├── Makefile
│   │   ├── .env.example
│   │   └── service.yaml
│   │
│   ├── go-api/
│   │   ├── cmd/server/
│   │   ├── internal/
│   │   ├── go.mod
│   │   ├── Dockerfile
│   │   ├── Makefile
│   │   ├── .env.example
│   │   └── service.yaml
│   │
│   ├── node-api/
│   │   ├── src/
│   │   ├── package.json
│   │   ├── tsconfig.json
│   │   ├── Dockerfile
│   │   ├── Makefile
│   │   ├── .env.example
│   │   └── service.yaml
│   │
│   └── python-api/
│       ├── app/
│       ├── tests/
│       ├── requirements.txt
│       ├── Dockerfile
│       ├── Makefile
│       ├── .env.example
│       └── service.yaml
│
├── shared/
│   ├── helm/
│   │   └── platform-service/
│   │       ├── Chart.yaml
│   │       ├── values.yaml
│   │       └── templates/
│   │           ├── deployment.yaml
│   │           ├── service.yaml
│   │           └── hpa.yaml
│   │
│   └── ci/
│       ├── ci-template.yml
│       ├── example-service-workflow.yml
│       └── .github/workflows/
│           └── platform-service.yml
│
└── docs/
    ├── SERVICE-CONTRACT.md
    ├── SERVICE-YAML-SCHEMA.md
    ├── NAMING-CONVENTIONS.md
    ├── PHASE1-IMPLEMENTATION.md
    ├── TRADEOFFS-AND-MISTAKES.md
    └── LAYER-RESPONSIBILITIES.md
```

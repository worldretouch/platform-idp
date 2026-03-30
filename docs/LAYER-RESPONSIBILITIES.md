# Layer Responsibilities — What Goes Where

## Layer 1: Shared Base Template (`base-template/`)

**Purpose**: Standards that apply to ALL services, regardless of runtime.

| Artifact | Purpose |
|----------|---------|
| README.md template | Service overview, quick start |
| Makefile | Common targets (help, docker-build, docker-push) |
| .env.example | Env var contract |
| service.yaml | Metadata for Port.io catalog, scaffolding |
| docs/ownership.md | Owner, escalation |
| docs/runbook.md | Ops procedures |
| docs/service-contract.md | Per-service contract summary |
| Dockerfile.conventions.md | Image standards |
| CI.conventions.md | Pipeline expectations |

**Does NOT contain**: Runtime-specific code. No Ruby, Go, Node, or Python.

---

## Layer 2: Runtime Starters (`starters/{runtime}-api/`)

**Purpose**: Bootstrap code for a specific runtime.

| Artifact | Purpose |
|----------|---------|
| App structure | Framework setup (Rails, Express, FastAPI, etc.) |
| Config loading | Read PORT, APP_ENV, DATABASE_URL, etc. |
| Health endpoints | Implement /health/live, /health/ready |
| Logging bootstrap | Structured logging |
| Dockerfile | Runtime-specific build |
| Makefile overrides | deps, run, test, lint, build |
| Tests | Example health tests |

**Consumes**: Base template conventions. References `../../base-template/` for Makefile include, docs.

---

## Shared Helm Chart (`shared/helm/platform-service/`)

**Purpose**: Deploy any platform service to Kubernetes.

| Contains | Purpose |
|----------|---------|
| Deployment | Container spec, probes, resources |
| Service | ClusterIP |
| HPA | Autoscaling |
| values.yaml | Service name, image, env, resources |

**Used by**: Argo CD, helm install, Terraform helm_release.

**Does NOT contain**: Application code. Only K8s manifests.

---

## Shared CI Templates (`shared/ci/`)

**Purpose**: Reusable pipeline for platform services.

| Contains | Purpose |
|----------|---------|
| ci-template.yml | Lint, test, build, scan, publish |
| platform-service.yml | Reusable workflow (if using workflow_call) |

**Used by**: Copy to service repo `.github/workflows/ci.yml`, or call from reusable workflow.

**Runtime-specific**: Each service may need different `deps` (bundle, npm, pip). Template documents; service customizes.

---

## Developer portal (Port.io)

**Purpose**: Service catalog, self-service actions, and scaffolding — **hosted by Port** (SaaS), not in this repo.

**Composes** (conceptually):
1. Base template (docs, service.yaml, .env.example)
2. Runtime starter (Rails OR Go OR Node OR Python)
3. Optional: CI workflow, Helm values — wired via Port blueprints and integrations

**Output**: New repo or folder with merged content, driven by Port configuration outside `platform-idp`.

---

## Summary Matrix

| Concern | Base | Runtime Starter | Helm | CI |
|---------|------|-----------------|------|-----|
| Env naming | ✓ | reads | injects | — |
| Health contract | ✓ | implements | probes | — |
| service.yaml | ✓ | has copy | — | — |
| Dockerfile | conventions | ✓ | — | builds |
| Makefile | common | overrides | — | runs |
| K8s manifests | — | — | ✓ | — |
| Pipeline steps | conventions | — | — | ✓ |

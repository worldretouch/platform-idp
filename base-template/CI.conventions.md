# CI Conventions

All services MUST run these pipeline steps.

## Required Steps

| Step | Purpose | Failure = Block |
|------|---------|-----------------|
| Contract Validate | Validate `service.yaml` against platform schema | Yes |
| Lint | Code style, static analysis | Yes |
| Test | Unit tests, coverage | Yes |
| Build | Produce container image | Yes |
| Security Scan | Image vulnerability scan (Trivy) | Yes (HIGH/CRITICAL) |
| Publish | Push image to registry | On main/tags only |

## Image Tagging

- `{git-sha}` — immutable, from every commit
- `{branch}-latest` — latest for branch (e.g., `main-latest`)
- `v{version}` — from git tags

## Triggers

- **PR**: Lint, Test, Build (no publish)
- **Push to main**: Lint, Test, Build, Publish
- **Tag**: Lint, Test, Build, Publish (release)

## Conventions

- Use reusable workflows where possible (GitHub Actions) or shared templates
- Cache dependencies between jobs
- Fail fast on lint/test before build
- Fail CI on HIGH/CRITICAL vulnerabilities for main/prod paths
- Upload SARIF results to GitHub code scanning
- Keep `service.yaml` at repo root and validate it in CI

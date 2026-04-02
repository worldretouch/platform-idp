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

## GitHub Actions

- Each service includes `.github/workflows/ci.yml`, a thin wrapper that calls  
  `{org}/platform-idp/.github/workflows/platform-service.yml@{ref}` (rendered at scaffold time).
- The wrapper declares `contents: write` and `pull-requests: write` so the reusable workflow’s **update-dev-values** job (opens a PR on `platform-env`) is allowed. GitHub intersects caller and callee permissions; too-narrow caller permissions cause workflow validation errors.
- **`ENV_REPO_TOKEN`**: a PAT with `repo` (and `workflow` if needed) on `platform-env` for promote/GitOps steps the reusable workflow expects.
- **Prefer an organization secret** named `ENV_REPO_TOKEN` (Settings → Organization secrets → Actions) and grant access to your service repos. Workflows resolve org secrets the same as repo secrets, so you do **not** need to configure this per service repository unless you override at repo level.

## Conventions

- Use reusable workflows where possible (GitHub Actions) or shared templates
- Cache dependencies between jobs
- Fail fast on lint/test before build
- Fail CI on HIGH/CRITICAL vulnerabilities for main/prod paths
- Upload SARIF results to GitHub code scanning
- Keep `service.yaml` at repo root and validate it in CI

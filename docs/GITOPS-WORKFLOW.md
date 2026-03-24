# GitOps Workflow (ArgoCD Default)

This document defines the deployment flow for platform services using ArgoCD + GitOps.

## Goals

- Keep deployment state in Git.
- Promote immutable image tags across environments.
- Provide auditable approvals for staging/prod.
- Make rollback a simple Git revert.

## Repositories

- **Service repo**: application code, CI, image build.
- **Template repo**: this repo (`platform-idp`) with shared chart/workflows.
- **Environment repo**: desired deployment state (`platform-env`), watched by ArgoCD.

## Environment model

- `dev`: automatic promotion from CI (optional, but recommended).
- `staging`: manual approval via PR.
- `prod`: manual approval via PR + change controls.

## Deployment flow

1. Developer merges to `main` in service repo.
2. CI builds image and pushes immutable tag (git SHA).
3. CI creates PR in environment repo updating:
   - `environments/dev/values/<service>.values.yaml` -> `image.tag=<sha>`
4. ArgoCD syncs `dev` after merge.
5. Promote by opening PR from current `dev` tag to `staging`, then `prod`.
6. ArgoCD syncs each environment after PR merge.

## Rollback flow

1. Find last known good tag from Git history in environment repo.
2. Revert the commit that changed `image.tag` (or set previous tag in a new PR).
3. Merge rollback PR.
4. ArgoCD self-heals to previous revision.

## Guardrails

- Never use `latest` tag in staging/prod.
- Use PR approvals for staging/prod promotions.
- Keep ArgoCD `Application` specs in Git.
- Keep environment-specific secrets outside Git (e.g., External Secrets/Vault).

## Bootstrap steps

1. Run:
   - `bash shared/gitops/bootstrap-env-repo.sh --target-dir ../platform-env --env-repo-url <env-repo-url> --template-repo-url <template-repo-url>`
   - Optional preview: add `--dry-run`
2. Apply:
   - `argocd/project-platform-services.yaml`
   - `argocd/root-app.yaml`
3. Add service-specific app manifests and values files.

## Production tag policy

- CI enforces that production values files never use `image.tag: latest`.
- CI enforces that production values tags are SHA-like (`sha-<hex>` or `<hex>`).
- Disallowed tags in prod values:
  - `latest`
  - `main-latest`
  - `prod-latest`

## Dev update automation

- Reusable workflow `shared/ci/.github/workflows/platform-service.yml` can auto-open dev update PR after publish.
- To enable in a service repo workflow call:
  - set input: `env_repo: myorg/platform-env`
  - set secret: `env_repo_token` (PAT/app token with write access to env repo)
- Fallback/manual template remains available:
  - `shared/gitops/update-dev-values-after-publish.example.yml`


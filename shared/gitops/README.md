# GitOps Skeleton (ArgoCD)

This folder provides a ready-to-copy baseline for a separate environment config repository
(`platform-env` or similar) managed by ArgoCD.

All manifests use standardized placeholder tokens:

- `__PLATFORM_ENV_REPO_URL__`
- `__PLATFORM_TEMPLATE_REPO_URL__`
- `__ARGOCD_NAMESPACE__`
- `__CLUSTER_API_SERVER__`

## Structure

- `argocd/`:
  - `project-platform-services.yaml`: ArgoCD project guardrails.
  - `root-app.yaml`: app-of-apps entrypoint for environment apps.
- `environments/`:
  - `dev/`, `staging/`, `prod/`: environment overlays and service app manifests.

## How to use

1. Run bootstrap script:
   - `bash shared/gitops/bootstrap-env-repo.sh --target-dir ../platform-env --env-repo-url <env-repo-url> --template-repo-url <template-repo-url>`
   - Preview only: add `--dry-run`
2. Add one service app in `environments/dev/apps/`.
3. Promote by copying the same image tag from `dev` -> `staging` -> `prod`.
4. Rollback by restoring the previous image tag via Git revert.

## Promotion model

- Always deploy immutable image tags (git SHA), never `latest` in prod.
- Promotion is Git PR based:
  - CI publishes image.
  - CI opens PR to update `dev` (see `update-dev-values-after-publish.example.yml`).
  - Humans approve promotion PRs for `staging` and `prod`.


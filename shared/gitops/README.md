# GitOps Skeleton (ArgoCD)

This folder provides a ready-to-copy baseline for a separate environment config repository
(`platform-env` or similar) managed by ArgoCD.

## Structure

- `argocd/`:
  - `project-platform-services.yaml`: ArgoCD project guardrails.
  - `root-app.yaml`: app-of-apps entrypoint for environment apps.
- `environments/`:
  - `dev/`, `staging/`, `prod/`: environment overlays and service app manifests.

## How to use

1. Copy `shared/gitops/` into your environment repo.
2. Update `repoURL` in ArgoCD app manifests to your env repo URL.
3. Add one service app in `environments/dev/apps/`.
4. Promote by copying the same image tag from `dev` -> `staging` -> `prod`.
5. Rollback by restoring the previous image tag via Git revert.

## Promotion model

- Always deploy immutable image tags (git SHA), never `latest` in prod.
- Promotion is Git PR based:
  - CI publishes image.
  - CI opens PR to update `dev`.
  - Humans approve promotion PRs for `staging` and `prod`.


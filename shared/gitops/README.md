# GitOps Skeleton (ArgoCD)

This folder provides a ready-to-copy baseline for a separate environment config repository
(`platform-env` or similar) managed by ArgoCD.

All manifests use standardized placeholder tokens:

- `__PLATFORM_ENV_REPO_URL__`
- `__PLATFORM_TEMPLATE_REPO_URL__`
- `__GITHUB_ORG__` (GHCR image path `ghcr.io/<org>/<service>`; set via `--github-org`)
- `__ARGOCD_NAMESPACE__`
- `__CLUSTER_API_SERVER__`

## Structure

- `argocd/`:
  - `project-platform-services.yaml`: ArgoCD project guardrails.
  - `platform-argocd-config-app.yaml`: Application that syncs **only** `project-platform-services.yaml` from this repo (GitOps for the AppProject). Apply once; then commit-only updates.
  - `root-app.yaml`: app-of-apps entrypoint for environment apps.
- `environments/`:
  - `dev/`, `staging/`, `prod/`: environment overlays and service app manifests.

## GitOps for `AppProject` (no more manual `kubectl` for project edits)

`platform-root` syncs path `environments/` only, so **`argocd/project-platform-services.yaml` is not applied by the root app**.

To make AppProject changes **commit-only**:

1. Ensure `argocd/platform-argocd-config-app.yaml` exists in `platform-env` (bootstrap copies it).
2. **One-time** on the cluster:

   ```bash
   kubectl apply -n argocd -f argocd/platform-argocd-config-app.yaml
   ```

3. After that, any merge to `main` that changes `project-platform-services.yaml` is picked up by Argo CD automatically.

This Application uses **project `default`** so it does not depend on `platform-services` (which it deploys).

## How to use

1. Run bootstrap script (set your GitHub org for GHCR, e.g. `worldretouch`):
  - `bash shared/gitops/bootstrap-env-repo.sh --target-dir ../platform-env --env-repo-url <env-repo-url> --template-repo-url <template-repo-url> --github-org <org>`
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


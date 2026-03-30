# Release workflow (dev → staging → prod)

This document describes the **golden path** for releasing a service that uses this platform template.

The examples assume:
- Service repo: `orders-api`
- Template repo: `platform-idp`
- Environment repo: `platform-env`

## 0. Preconditions

- Service repo is wired to the reusable CI workflow:
  - `.github/workflows/ci.yml` calls `worldretouch/platform-idp/.github/workflows/platform-service.yml@main`.
- Env repo `platform-env` is bootstrapped from `shared/gitops/` and managed by Argo CD.
- `platform-env` has the promotion workflow:
  - `.github/workflows/promote-to-env.yml` (see `shared/gitops/promote-to-env.example.yml`).
- GHCR and secrets:
  - Images are published to `ghcr.io/<org>/<service>`.
  - Each namespace (`platform-dev`, `platform-staging`, `platform-prod`) has a `docker-registry` secret (e.g. `ghcr-pull`) referenced via `imagePullSecrets`.

## 1. From code to dev

1. Developer opens PR in the **service repo** (e.g. `orders-api`).
2. CI runs on the PR: lint, test, build.
3. After review, PR is merged to `main`.
4. CI on `main`:
   - Builds and scans the image.
   - Publishes `ghcr.io/<org>/<service>:<git-sha>`.
   - Signs the image with cosign (keyless).
   - Updates **dev** values in the env repo (either by PR or direct commit), setting:
     - `environments/dev/values/<service>.values.yaml` → `image.tag: "<git-sha>"`.
5. Argo CD syncs `orders-api-dev` and rolls out the new image to `platform-dev`.
6. Team validates the change on dev (smoke tests, quick checks).

## 2. Promote to staging

There are two options, depending on how much automation you enable.

### 2.1. Manual Git change (baseline)

1. In `platform-env`, update:
   - `environments/staging/values/<service>.values.yaml` → `image.tag: "<git-sha>"`  
     (ideally the same SHA currently running and validated on dev).
2. Open a PR `main <- feature` in `platform-env`.
3. Review and merge the PR.
4. Argo CD syncs `orders-api-staging` and rolls out the new image to `platform-staging`.
5. Team validates on staging (regression tests, UAT, etc.).

### 2.2. Using the promotion workflow (recommended)

1. Go to the **Actions** tab of `platform-env`.
2. Run workflow **“Promote service to environment”** with:
   - `service_name`: e.g. `orders-api`
   - `environment`: `staging`
   - `image_tag`: the git SHA that should be promoted
   - `image_repository` (optional): leave empty to default to `ghcr.io/<org>/<service>`
3. The workflow:
   - Updates `environments/staging/values/<service>.values.yaml` with the new `image.tag`.
   - Opens a promotion PR (branch `gitops/staging/<service>-<sha>`).
4. Review and merge the PR.
5. Argo CD syncs `orders-api-staging`.

## 3. Promote to production

Production has additional gates.

1. Ensure staging is healthy and functionally validated.
2. Verify the image signature (this can be done locally or inside the promotion workflow):

   ```bash
   cosign verify ghcr.io/<org>/<service>:<git-sha> \
     --certificate-oidc-issuer https://token.actions.githubusercontent.com \
     --certificate-identity-regexp "https://github.com/.+/.+/.+"
   ```

3. In `platform-env`, use one of:

### 3.1. Manual Git change (baseline)

1. Update:
   - `environments/prod/values/<service>.values.yaml` → `image.tag: "<git-sha>"`  
     (typically the same SHA that is already running on staging).
2. Open a PR and have it approved according to `docs/PROD-PROMOTION-POLICY.md`:
   - CI green.
   - Immutable SHA-like tag.
   - SBOM and signature exist.
   - At least service owner + platform/on-call approver.
3. Merge the PR.
4. Argo CD syncs `orders-api-prod`.

### 3.2. Using the promotion workflow (recommended)

1. Go to **Actions** in `platform-env`.
2. Run **“Promote service to environment”** with:
   - `service_name`: e.g. `orders-api`
   - `environment`: `prod`
   - `image_tag`: the git SHA from staging
3. The workflow:
   - Logs into GHCR (for private images).
   - Runs `cosign verify` for the image.
   - Updates `environments/prod/values/<service>.values.yaml` `image.tag`.
   - Opens a production promotion PR (`gitops/prod/<service>-<sha>`).
4. Review the PR against `docs/PROD-PROMOTION-POLICY.md` and merge.
5. Argo CD syncs `orders-api-prod`. Monitor and smoke‑test production.

## 4. Rollback

Rolling back is always a Git change.

1. Identify the last known good image tag:
   - From `git log` in `platform-env`, or
   - From Argo CD application history.
2. Either:
   - Revert the commit that changed `image.tag`, **or**
   - Open a new PR that sets `image.tag` back to the previous SHA.
3. Merge the PR.
4. Argo CD syncs and rolls back the Deployment.


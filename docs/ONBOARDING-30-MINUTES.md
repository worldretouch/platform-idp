# Onboarding in 30 Minutes

This guide gets a new team from zero to a deployed platform service using the standard path.

## Prerequisites (5 minutes)

- Access to GitHub org repositories:
  - service repo
  - environment repo (`platform-env`)
- Access to Kubernetes/ArgoCD environment
- Docker, runtime toolchain, and `make` installed
- Required secrets configured in GitHub:
  - `GITHUB_TOKEN` (registry push)
  - `ENV_REPO_TOKEN` (env repo PR automation)

## Step 1: Scaffold a service (5 minutes)

```bash
make scaffold RUNTIME=node SERVICE_NAME=orders-api OUTPUT_DIR=../orders-api
cd ../orders-api
```

Validate scaffold outputs:

- `.platform-template-version`
- `service.yaml`
- `Makefile`, `Dockerfile`, `.env.example`

## Step 2: Run locally (5 minutes)

```bash
make init
make run
curl http://localhost:3000/health/live
curl http://localhost:3000/health/ready
```

Send a correlation test request:

```bash
curl -H "x-request-id: req-onboarding-1" -H "x-trace-id: trace-onboarding-1" \
  http://localhost:3000/health/live
```

## Step 3: Enable reusable platform CI (5 minutes)

Use `shared/ci/example-service-workflow.yml` as base:

- set `service_name`
- set `runtime`
- set `env_repo`
- provide `env_repo_token`

Expected on merge:

- lint/test/security gates
- image publish
- SBOM artifact
- cosign sign + verify
- dev env PR opened automatically

## Step 4: Bootstrap environment repo GitOps (5 minutes)

```bash
bash shared/gitops/bootstrap-env-repo.sh \
  --target-dir ../platform-env \
  --env-repo-url https://github.com/<org>/platform-env.git \
  --template-repo-url https://github.com/<org>/platform-idp.git
```

Apply ArgoCD root/project manifests from env repo:

- `argocd/project-platform-services.yaml`
- `argocd/root-app.yaml`

## Step 5: First deployment and promotion (10 minutes)

1. Merge service PR to `main`.
2. Confirm dev values PR is created and merged.
3. Confirm ArgoCD syncs `dev`.
4. Promote to `staging` using Git PR.
5. Promote to `prod` using `shared/gitops/prod-promotion.yml` flow (signature verify gate).

## Done Criteria

- Service is running in `dev` and health checks pass.
- Promotion PR to `staging` is merged successfully.
- Production promotion path is verified with cosign check.
- No manual kubectl patching required.


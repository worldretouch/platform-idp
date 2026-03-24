# Security/Ops Runbook

Runbook for incidents related to image signatures, SBOM, and production rollback.

## 1) Signature verification failure

Symptoms:

- prod promotion workflow fails at cosign verify

Checklist:

1. Confirm image tag exists in registry.
2. Verify workflow identity/issuer is expected.
3. Re-run verify command locally from CI logs.
4. Check whether image was signed in publish job.
5. If unsigned, block promotion and trigger rebuild/re-sign.

## 2) SBOM generation/upload failure

Symptoms:

- publish workflow fails at SBOM generation/upload

Checklist:

1. Confirm image was built and pushed successfully.
2. Retry SBOM generation action.
3. Check action pin/availability and network access.
4. If recurring, open platform incident and freeze prod promotions for affected services.

## 3) Vulnerability escalation after deploy

Checklist:

1. Identify affected image tags from registry.
2. Compare SBOM to vulnerability advisory scope.
3. Roll forward to patched image if available.
4. If no patch, reduce exposure (feature flags, traffic limits) and create risk exception.

## 4) Production rollback

Preferred approach:

1. Revert env repo commit that changed `image.tag`.
2. Merge rollback PR.
3. Verify ArgoCD sync and service health.
4. Announce incident status in ops channel.

## Communication template

- Service:
- Environment:
- Current tag:
- Target tag:
- Reason:
- Risk:
- Approval:


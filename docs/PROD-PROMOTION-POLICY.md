# Production Promotion Policy

This policy defines mandatory gates before promoting any service to production.

## Required gates

1. CI status must be green (lint, test, build, security, parity checks).
2. Image tag must be immutable and SHA-like.
3. SBOM must be generated and stored as CI artifact.
4. Image signature must exist and verify with cosign.
5. Promotion must happen via PR to env repo (`environments/prod/values/*.yaml`).
6. PR must be approved by service owner and platform/on-call approver.

## Disallowed

- Direct manual patching in cluster for normal promotions.
- `latest`-like tags in production values.
- Promotion without traceable PR and reviewer approvals.

## Verification commands

```bash
cosign verify ghcr.io/<org>/<service>:<sha> \
  --certificate-oidc-issuer https://token.actions.githubusercontent.com
```

## Exceptions

Emergency exceptions require:

- incident ticket reference
- post-incident review
- remediation follow-up PR to restore standard process


# GA Readiness Checklist

Gate checklist to declare the platform template generally available.

## Platform Capability Gates

- [ ] Standard scaffold works for all 4 runtimes
- [ ] Service contract validation is enforced in CI
- [ ] Runtime parity check is enforced in CI
- [ ] GitOps dev/staging/prod flow is documented and used
- [ ] Production promotion uses mandatory signature verification

## Security Gates

- [ ] High/Critical vulnerability gating enforced
- [ ] SBOM generation is enabled in release pipeline
- [ ] Cosign signing is enabled for published images
- [ ] Cosign verify is enforced before prod promotion
- [ ] Action references are pinned to commit SHAs

## Observability Gates

- [ ] Starter runtimes emit `request_id` and `trace_id`
- [ ] Observability smoke workflow passes for all runtimes
- [ ] Health endpoints and semantics are consistent
- [ ] Baseline alert rules are available

## Operational Readiness Gates

- [ ] Security/Ops runbook exists and was exercised
- [ ] Rollback flow tested in pilot
- [ ] Incident communication template available
- [ ] Ownership and approval matrix agreed

## Adoption Gates

- [ ] At least 2 pilot teams completed end-to-end flow
- [ ] Both teams deployed without manual DevOps intervention
- [ ] Platform onboarding completed in <= 30 minutes for pilot teams
- [ ] Known gaps have owners and target dates

## GA Decision

- [ ] Approve GA
- [ ] Defer GA (list blockers + ETA)


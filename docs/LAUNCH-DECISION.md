# Launch Decision (GA)

Use this one-page form to make the final go/no-go decision for platform template GA.

Date: `YYYY-MM-DD`  
Release/Version: `vX.Y.Z`  
Decision Owner: `<name>`

## 1) Gate Summary (must be Yes)

- [ ] Capability gates passed (`docs/GA-READINESS-CHECKLIST.md`)
- [ ] Security gates passed (`docs/PROD-PROMOTION-POLICY.md`)
- [ ] Observability gates passed (`docs/OBSERVABILITY-STANDARDS.md`)
- [ ] Pilot rollout passed for 2 teams (`docs/PILOT-ROLLOUT-CHECKLIST.md`)
- [ ] Security/Ops runbook reviewed (`docs/SECURITY-OPS-RUNBOOK.md`)

## 2) Metrics Snapshot

- Time-to-first-deploy (pilot median): `___` minutes
- Deploy success rate (pilot): `___%`
- Number of required DevOps tickets during pilot: `___`
- Critical blocker count open: `___`

## 3) Open Risks (if any)

1. `Risk:`  
   `Mitigation:`  
   `Owner:`  
   `Due:`

2. `Risk:`  
   `Mitigation:`  
   `Owner:`  
   `Due:`

## 4) Final Decision

- [ ] **GO (GA approved)**
- [ ] **NO-GO (defer GA)**

If NO-GO, list blockers and target date:

- Blocker 1:
- Blocker 2:
- Re-evaluation date:

## 5) Sign-off

- Platform Lead: `__________________`  Date: `________`
- Security Lead: `__________________`  Date: `________`
- SRE/Ops Lead: `__________________`  Date: `________`
- Product/Engineering Manager: `__________________`  Date: `________`


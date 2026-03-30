Detail từng phase
Phase 0 — Governance & Baseline
Xác định ownership/RACI cho template và runtime.
Policy versioning, release cadence, deprecation.
KPI nền tảng (time-to-first-deploy, adoption, failure rate).
Phase 1 — Enforcement (đã xong)
Enforce service.yaml schema trong CI.
Security scan fail High/Critical.
Chuẩn hóa CI reusable workflow + SARIF upload.
Docker baseline chuẩn hơn (metadata labels, non-root, conventions sync).
Phase 2 — Drift Control + DX
Chống drift sau scaffold:
gắn platform_template_version vào service được generate.
Chuẩn hóa bootstrap local:
make init cho tất cả runtime.
Dọn template hygiene:
loại artifact không nên commit (vd node_modules, dist trong starter).
Mục tiêu: tạo service mới nhanh, ít lỗi, dễ upgrade.
Phase 3 — GitOps Default (ArgoCD)
Thiết kế env flow dev/staging/prod.
CI publish image immutable -> mở PR update env manifests.
ArgoCD sync làm source of truth deploy.
Có promotion + rollback chuẩn.
Phase 4 — Observability + Security by Default
Starter có logging/metrics/tracing mặc định (otel-friendly).
Dashboard/alert baseline theo service contract.
SBOM + signing/attestation trong CI.
Policy chặn image/tag/manifests không đạt chuẩn.
Progress:
- Added shared observability baseline docs/templates.
- Added SBOM generation in reusable CI publish job.
- Added cosign signing in reusable CI and verify gate before prod promotion.
- Wired trace_id/request_id logging into all 4 runtime starters.
- Added CI policy requiring observability test coverage for trace_id/request_id.
- Added production promotion workflow with mandatory cosign verify gate.
- Pinned GitHub Action references to commit SHAs in core workflows.
- Added runtime parity policy checker and CI gate.
- Added production promotion policy and security/ops runbook docs.
Phase 5 — Onboarding + Launch
Onboarding guide 30 phút (CLI + Port.io developer portal).
Dry-run với team pilot.
Checklist GA “no DevOps ticket for standard path”.
Progress:
- Added `docs/ONBOARDING-30-MINUTES.md`.
- Added pilot checklist for 2 teams in `docs/PILOT-ROLLOUT-CHECKLIST.md`.
- Added launch gate checklist in `docs/GA-READINESS-CHECKLIST.md`.

Phase 6 — Developer Portal (Port.io)
**Prerequisite:** All four runtimes stable (scaffold, CI, observability smoke, parity) before rolling out catalog and self-service flows in Port.
**Note:** Portal is **SaaS (Port.io)** — not hosted in-cluster; integrate catalog (`service.yaml`, repos) and actions per Port docs.
Progress:
- _TBD_
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
Phase 5 — Onboarding + Launch
Onboarding guide 30 phút (CLI + Backstage).
Dry-run với team pilot.
Checklist GA “no DevOps ticket for standard path”.
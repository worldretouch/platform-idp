# Phase 1 Implementation Plan

## Recommended Approach: Single Monorepo

**Use one monorepo (`platform-idp`) for all platform templates.**

### Why Monorepo

| Factor | Monorepo | Multi-repo |
|--------|----------|------------|
| Cross-template updates | Single PR, atomic | N repos, coordination |
| Versioning | One version for platform | Per-repo versions |
| Onboarding | One clone | Multiple clones |
| CI for templates | One pipeline | N pipelines |
| Team size | Best for small-medium | Better for large, independent teams |

**Recommendation**: Start with monorepo. Split only if templates evolve independently and different teams own them.

---

## Phase 1 MVP Scope (Weeks 1–2)

### Week 1: Foundation

1. **Day 1–2**: Finalize base template
   - [ ] Review and adopt `base-template/`
   - [ ] Add `make scaffold` script (optional)
   - [ ] Document in `docs/`

2. **Day 3–4**: One runtime E2E
   - [ ] Pick **Go** as first runtime (simplest, fastest feedback)
   - [ ] Validate: `make deps && make run && make test`
   - [ ] Validate: `docker build` and `docker run`
   - [ ] Validate: health endpoints work

3. **Day 5**: Shared Helm chart
   - [ ] Deploy Go service to dev cluster using `shared/helm/platform-service`
   - [ ] Verify probes, service, HPA

### Week 2: Runtimes + CI

4. **Day 1–2**: Add Node.js and Python starters
   - [ ] Copy patterns from Go
   - [ ] Validate each: run, test, docker build

5. **Day 3**: Add Rails starter
   - [ ] Rails-specific config (DB, Redis)
   - [ ] Validate

6. **Day 4**: CI template
   - [ ] Copy `shared/ci/ci-template.yml` to each starter
   - [ ] Add runtime-specific steps (e.g., `bundle install` for Rails)
   - [ ] Test on one service

7. **Day 5**: Documentation + handoff
   - [ ] Update README, SERVICE-CONTRACT, runbooks
   - [ ] Create first real service from a starter
   - [ ] Retro and backlog for Phase 2

---

## Implementation Order

```
1. base-template (conventions, docs)
2. go-api starter (reference implementation)
3. shared/helm/platform-service
4. node-api, python-api starters
5. rails-api starter
6. shared/ci templates
7. First production service
```

---

## What to Defer

- **Port.io (developer portal)**: Phase 2 — after 2–3 services use the templates
- **Terraform**: Phase 2 — when you need app infra provisioning
- **Argo CD**: Phase 2 — when you have multiple envs and GitOps
- **Vault integration**: Phase 2 — when secrets management is required

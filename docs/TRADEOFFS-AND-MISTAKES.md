# Tradeoffs and Common Mistakes

## Repository Strategy

### Monorepo vs Multi-repo

| Choose Monorepo when | Choose Multi-repo when |
|----------------------|------------------------|
| Small-medium team (< 50) | Large org, many teams |
| Templates change together | Templates owned by different teams |
| Single platform team | Distributed ownership |
| Fast iteration | Strict isolation needed |

**Common mistake**: Splitting too early. Start monorepo; split only when pain is real.

---

## Template Design

### What Belongs Where

| Location | Contents |
|----------|----------|
| **Base template** | Conventions, docs, service.yaml, .env.example, Makefile targets |
| **Runtime starter** | Bootstrap code, framework setup, health impl, Dockerfile |
| **Shared Helm chart** | K8s Deployment, Service, HPA, probes |
| **Shared CI** | Lint, test, build, scan, publish |
| **Backstage (future)** | Software template that composes base + runtime |

**Common mistake**: Putting runtime-specific code in base template. Base = contract only.

---

## Common Mistakes

### 1. Over-standardizing application code

**Wrong**: Forcing identical project structure across Rails, Go, Node, Python.

**Right**: Standardize the *outer contract* (health, env, probes). Let each runtime use idiomatic structure.

### 2. Baking secrets into images

**Wrong**: `ENV DATABASE_URL=...` in Dockerfile.

**Right**: Inject at runtime via ConfigMap/Secret, Vault, or K8s native secrets.

### 3. Skipping health checks

**Wrong**: Using `/` or `/health` for both liveness and readiness.

**Right**: `/health/live` (no deps), `/health/ready` (checks DB, Redis). K8s uses both.

### 4. Inconsistent env naming

**Wrong**: `db_url`, `DBURL`, `database-url` across services.

**Right**: `DATABASE_URL` everywhere. Document in SERVICE-CONTRACT.

### 5. Makefile include order

**Wrong**: `include` at end overrides your targets.

**Right**: `include` first, then define overrides. Last definition wins in Make.

### 6. Helm chart too generic

**Wrong**: One chart that tries to handle workers, cron, APIs.

**Right**: `platform-service` chart for HTTP APIs only. Separate charts for workers/cron.

### 7. CI without caching

**Wrong**: Full `npm install` / `bundle install` every run.

**Right**: Cache dependencies. Use `actions/cache` or similar.

### 8. No graceful shutdown

**Wrong**: Process killed immediately on SIGTERM.

**Right**: Handle SIGTERM, drain connections, exit within 30s. K8s gives 30s by default.

---

## Evolution Path

```
Phase 1: Templates + Helm + CI (this deliverable)
    ↓
Phase 2: Argo CD + GitOps
    ↓
Phase 3: Backstage software templates
    ↓
Phase 4: Terraform app provisioning
    ↓
Phase 5: Full IDP (catalog, SRE, cost)
```

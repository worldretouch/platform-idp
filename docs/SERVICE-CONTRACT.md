# Shared Service Contract

All services built from platform templates MUST adhere to this contract.

## Required Environment Variables

| Variable | Required | Description | Example |
|----------|----------|-------------|---------|
| `PORT` | Yes | HTTP listen port | `3000` |
| `APP_ENV` | Yes | Environment name | `development`, `staging`, `production` |
| `LOG_LEVEL` | No | Log verbosity | `debug`, `info`, `warn`, `error` (default: `info`) |
| `DATABASE_URL` | If DB | PostgreSQL connection string | `postgres://user:pass@host:5432/db` |
| `REDIS_URL` | If cache | Redis connection string | `redis://host:6379/0` |
| `RABBITMQ_URL` | If broker | RabbitMQ connection string | `amqp://user:pass@host:5672/vhost` |

## Health Endpoints

| Endpoint | Method | Purpose |
|----------|--------|---------|
| `/health/live` | GET | Liveness — process is running |
| `/health/ready` | GET | Readiness — ready for traffic (checks DB, Redis, etc.) |

### Response Format

```json
{
  "status": "ok",
  "timestamp": "2025-03-12T10:00:00Z",
  "version": "1.0.0",
  "checks": {
    "database": "ok",
    "redis": "ok"
  }
}
```

- **Liveness**: Returns 200 if process is alive. No dependency checks.
- **Readiness**: Returns 200 only if all required dependencies are reachable. Returns 503 otherwise.

## Standard Labels / Metadata

Services must expose metadata at `GET /metadata` (optional but recommended):

```json
{
  "service": "orders-api",
  "version": "1.0.0",
  "runtime": "go",
  "environment": "production"
}
```

## CI Expectations

1. **Lint** — language-specific linter
2. **Test** — unit tests, coverage threshold (e.g., 80%)
3. **Build** — produce container image
4. **Security scan** — image vulnerability scan (Trivy, Snyk)
5. **Publish** — push image to registry with tag `{git-sha}` and `{branch}-latest`

## Deploy Expectations

1. **Container**: Single container per service, non-root user
2. **Config**: Env vars from ConfigMap/Secret, not baked into image
3. **Probes**: Liveness and readiness use `/health/live` and `/health/ready`
4. **Graceful shutdown**: Handle SIGTERM, drain connections within 30s

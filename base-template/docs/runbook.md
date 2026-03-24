# Runbook — {{SERVICE_NAME}}

## Overview

- **Service**: {{SERVICE_NAME}}
- **Runtime**: {{RUNTIME}}
- **Health**: `/health/live`, `/health/ready`

## Common Operations

### Restart Service

```bash
# Kubernetes
kubectl rollout restart deployment/{{SERVICE_NAME}} -n {{NAMESPACE}}

# Local
make run
```

### Check Health

```bash
curl http://localhost:${PORT}/health/live
curl http://localhost:${PORT}/health/ready
```

### View Logs

```bash
kubectl logs -f deployment/{{SERVICE_NAME}} -n {{NAMESPACE}}
```

## Troubleshooting

### Service Unhealthy

1. Check pod status: `kubectl get pods -l app={{SERVICE_NAME}}`
2. Check readiness probe failures
3. Verify DATABASE_URL, REDIS_URL if used
4. Check recent deployments

### High Latency

1. Check metrics (CPU, memory, request latency)
2. Review slow query logs if DB-backed
3. Check Redis/cache hit rate

### Database Connection Issues

1. Verify DATABASE_URL in secrets
2. Check network policies
3. Verify DB is reachable from cluster

## Rollback

```bash
kubectl rollout undo deployment/{{SERVICE_NAME}} -n {{NAMESPACE}}
```

## Contacts

- Owner: {{OWNER_TEAM}}
- Platform: #platform-support

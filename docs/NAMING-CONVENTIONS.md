# Naming Conventions

## Repository Naming

| Type | Pattern | Example |
|------|---------|---------|
| Service repo | `{domain}-{service}` or `{service}-api` | `orders-api`, `inventory-service` |
| Platform templates | `platform-idp` (this repo) | — |
| Helm chart repo | `platform-helm-charts` | — |

## Template Naming

| Template | Pattern | Example |
|----------|---------|---------|
| Base template | `base-template` | Shared across all runtimes |
| Runtime starter | `{runtime}-api-starter` | `rails-api-starter`, `go-api-starter` |

## Environment Variables

- **Prefix**: Use `{SERVICE}_` for service-specific vars (e.g., `ORDERS_API_KEY`)
- **Standard vars**: See [SERVICE-CONTRACT.md](SERVICE-CONTRACT.md)
- **Format**: `SCREAMING_SNAKE_CASE`
- **Secrets**: Never commit; use `*_URL`, `*_SECRET`, `*_KEY`, `*_TOKEN` suffixes

## Secret Naming (Vault / K8s Secrets)

| Secret Type | Pattern | Example |
|-------------|---------|---------|
| Database | `{service}/database` | `orders-api/database` |
| Redis | `{service}/redis` | `orders-api/redis` |
| API keys | `{service}/api-keys` | `orders-api/api-keys` |
| Generic | `{service}/secrets` | `orders-api/secrets` |

## Kubernetes Labels

```
app.kubernetes.io/name: {service-name}
app.kubernetes.io/component: api
app.kubernetes.io/part-of: {domain}
platform.owner: {team-slug}
platform.runtime: {rails|go|node|python}
```

## Health Endpoints

- **Liveness**: `GET /health/live` — process alive
- **Readiness**: `GET /health/ready` — ready to receive traffic (checks deps)

# Service Contract — {{SERVICE_NAME}}

This service implements the [Platform Service Contract](../../docs/SERVICE-CONTRACT.md).

## Implemented Endpoints

| Endpoint | Status |
|----------|--------|
| `GET /health/live` | ✅ |
| `GET /health/ready` | ✅ |

## Dependencies

| Dependency | Required | Env Var |
|------------|----------|---------|
| PostgreSQL | Yes | DATABASE_URL |
| Redis | No | REDIS_URL |

## Environment Variables

See `.env.example` and [SERVICE-CONTRACT.md](../../docs/SERVICE-CONTRACT.md).

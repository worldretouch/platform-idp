# service.yaml Schema

Used by Backstage, scaffolding, platform automation, and Terraform.

## Full Schema

```yaml
# Required
service_name: string      # kebab-case, e.g. orders-api
runtime: string           # rails | go | node | python
owner: string             # team slug
domain: string            # business domain

# Optional
description: string       # multi-line supported
expose_http: boolean      # default true
health_path: string       # default /health/ready

dependencies:
  database: boolean       # uses PostgreSQL
  cache: boolean          # uses Redis
  broker: boolean        # uses RabbitMQ

deployment:
  replicas: number       # default 2
  resources:
    requests:
      cpu: string        # e.g. 100m
      memory: string     # e.g. 128Mi
    limits:
      cpu: string
      memory: string
  autoscaling:
    min_replicas: number
    max_replicas: number
    target_cpu_percent: number

observability:
  metrics: boolean
  tracing: boolean
  log_format: string     # json | text

repository:
  url: string
  main_branch: string    # default main
```

## Validation

- `service_name`: `^[a-z0-9]+(-[a-z0-9]+)*$`
- `runtime`: one of `rails`, `go`, `node`, `python`
- `owner`: non-empty string
- `domain`: non-empty string

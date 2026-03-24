# Rails API Starter

Bootstrap for a Rails API service following the platform service contract.

## Structure

```
rails-api/
├── app/
│   ├── controllers/
│   │   ├── application_controller.rb
│   │   └── health_controller.rb
│   └── ...
├── config/
│   ├── database.yml
│   ├── environments/
│   └── ...
├── Dockerfile
├── Makefile
├── .env.example
├── service.yaml
└── Gemfile
```

## Quick Start

```bash
make deps
make run
curl http://localhost:3000/health/ready
```

## Config Loading

Uses `ENV` directly. Database URL from `DATABASE_URL`, Redis from `REDIS_URL`.

## Health Endpoints

- `GET /health/live` — Rack process alive
- `GET /health/ready` — DB + Redis connectivity (if configured)

## Observability

`config/application.rb` defines log tags for correlation:

- `:request_id`
- trace id tag from `X-Trace-Id` header (fallback to request id)

Example request:

```bash
curl -H "X-Request-Id: req-123" -H "X-Trace-Id: trace-456" http://localhost:3000/health/live
```

Run observability test:

```bash
bundle exec rspec spec/requests/observability_spec.rb
```

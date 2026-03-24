# Go API Starter

Bootstrap for a Go HTTP service following the platform service contract.

## Structure

```
go-api/
├── cmd/
│   └── server/
│       └── main.go
├── internal/
│   ├── config/
│   │   └── config.go
│   ├── health/
│   │   └── handler.go
│   └── server/
│       └── server.go
├── Dockerfile
├── Makefile
├── go.mod
├── .env.example
└── service.yaml
```

## Quick Start

```bash
make deps
make run
curl http://localhost:3000/health/ready
```

## Config Loading

Uses `internal/config` — reads from `os.Getenv()`. See `config.go`.

## Health Endpoints

- `GET /health/live` — process alive
- `GET /health/ready` — DB + Redis connectivity (if configured)

## Observability

`internal/server/observability.go` provides:

- middleware that sets `X-Request-Id` and `X-Trace-Id`
- JSON request logging with `request_id` and `trace_id`

Example request:

```bash
curl -H "X-Request-Id: req-123" -H "X-Trace-Id: trace-456" http://localhost:3000/health/live
```

Run observability test:

```bash
go test ./internal/server -run TestRequestLogFields_ContainsTraceAndRequestID
```

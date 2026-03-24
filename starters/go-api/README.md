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

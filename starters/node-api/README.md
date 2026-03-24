# Node.js API Starter

Bootstrap for a Node.js HTTP service following the platform service contract.

## Structure

```
node-api/
├── src/
│   ├── index.ts
│   ├── config.ts
│   ├── health.ts
│   └── server.ts
├── Dockerfile
├── Makefile
├── package.json
├── tsconfig.json
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

Uses `src/config.ts` — reads from `process.env`. See platform contract.

## Health Endpoints

- `GET /health/live` — process alive
- `GET /health/ready` — DB + Redis connectivity (if configured)

## Observability

`src/server.ts` injects and emits correlation fields by default:

- `x-request-id` (generated if missing)
- `x-trace-id` (falls back to request id)
- JSON request log includes `request_id` and `trace_id`

Example request:

```bash
curl -H "x-request-id: req-123" -H "x-trace-id: trace-456" http://localhost:3000/health/live
```

Run observability test:

```bash
npx jest src/observability.test.ts
```

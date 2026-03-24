# Python API Starter

Bootstrap for a Python HTTP service following the platform service contract.

## Structure

```
python-api/
├── app/
│   ├── __init__.py
│   ├── main.py
│   ├── config.py
│   └── health.py
├── tests/
│   └── test_health.py
├── Dockerfile
├── Makefile
├── requirements.txt
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

Uses `app/config.py` — reads from `os.environ`. See platform contract.

## Health Endpoints

- `GET /health/live` — process alive
- `GET /health/ready` — DB + Redis connectivity (if configured)

## Observability

`app/main.py` middleware sets correlation headers and emits JSON logs:

- `x-request-id`
- `x-trace-id`
- structured fields including `request_id` and `trace_id`

Example request:

```bash
curl -H "x-request-id: req-123" -H "x-trace-id: trace-456" http://localhost:3000/health/live
```

Run observability test:

```bash
pytest tests/test_observability.py
```

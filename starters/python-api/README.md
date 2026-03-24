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

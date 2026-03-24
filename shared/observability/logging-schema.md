# Logging Schema (Platform Standard)

All production services should emit single-line JSON logs.

## Required fields

- `timestamp`: RFC3339 timestamp
- `level`: `debug|info|warn|error`
- `service`: service name (`service.yaml.service_name`)
- `environment`: `development|staging|production`
- `message`: human-readable event message
- `trace_id`: distributed trace id when available
- `request_id`: request correlation id when available

## Recommended fields

- `span_id`
- `http.method`
- `http.path`
- `http.status_code`
- `duration_ms`
- `user.id` (if known and non-sensitive)
- `error.type`
- `error.message`

## Example

```json
{
  "timestamp": "2026-03-24T10:12:34Z",
  "level": "info",
  "service": "orders-api",
  "environment": "production",
  "trace_id": "6f2e5e9fd31c84f08b2caeec6f8a8c09",
  "request_id": "req-9df8c1f4",
  "message": "request completed",
  "http.method": "GET",
  "http.path": "/orders/123",
  "http.status_code": 200,
  "duration_ms": 27
}
```


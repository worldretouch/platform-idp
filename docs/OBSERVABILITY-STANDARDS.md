# Observability Standards

Phase 4 baseline for all platform services.

## Minimum requirements

- Structured JSON logs with platform fields (see `shared/observability/logging-schema.md`)
- Metrics endpoint available for scraping
- Distributed tracing enabled through OpenTelemetry
- Health endpoints remain `/health/live` and `/health/ready`

## Runtime mapping

- Node: use OpenTelemetry JS SDK, include trace/request IDs in logs
- Go: use OpenTelemetry Go SDK and propagate W3C trace context
- Python: use OpenTelemetry Python auto/manual instrumentation
- Rails: use OpenTelemetry Ruby and request tagging in logs

## SLO starter targets

- Availability SLI: successful request ratio
- Latency SLI: p95 request latency
- Error budget policy per service domain

## Alerting baseline

Use `shared/observability/prometheus-rules.example.yaml` as a starter and tune thresholds per service.

## Template smoke tests

Template repo includes `/.github/workflows/observability-smoke.yml` to run runtime-level
observability tests for Node, Go, Python, and Rails starters.


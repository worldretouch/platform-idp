# Observability Baseline

This folder defines the default observability contract for platform services.

## Scope

- Structured JSON logging
- Metrics exposure for scraping
- OpenTelemetry tracing conventions

## Files

- `logging-schema.md`: required log fields and examples.
- `otel-env.example`: standard OTEL environment variables.
- `prometheus-rules.example.yaml`: baseline alerting rules template.

## Adoption

Each runtime starter should map this baseline to runtime-specific libraries:

- Node: pino/winston + OpenTelemetry JS
- Go: slog/zerolog + OpenTelemetry Go
- Python: structlog/logging + OpenTelemetry Python
- Rails: lograge + OpenTelemetry Ruby


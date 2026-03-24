# Dockerfile Conventions

All service images MUST follow these conventions.

## Requirements

1. **Multi-stage build** — separate build and runtime stages
2. **Non-root user** — run as unprivileged user (e.g., `app` or numeric UID)
3. **Minimal base** — use distroless or alpine where possible
4. **Single process** — one process per container
5. **No secrets in image** — inject via env at runtime
6. **OCI labels** — include source, revision, service, runtime metadata

## Structure

```dockerfile
# Stage 1: Build
FROM {runtime}-builder AS builder
WORKDIR /app
COPY . .
RUN make build  # or runtime-specific build

# Stage 2: Runtime
FROM {runtime}-slim
RUN adduser --disabled-password app
USER app
WORKDIR /app
COPY --from=builder /app/dist/ .
EXPOSE ${PORT}
CMD ["./app"]  # or runtime-specific entrypoint
```

## Labels

```dockerfile
LABEL org.opencontainers.image.source="https://github.com/myorg/service"
LABEL org.opencontainers.image.revision="${GIT_SHA}"
LABEL platform.service="${SERVICE_NAME}"
LABEL platform.runtime="${RUNTIME}"
```

## Port

Use `PORT` env var (default 3000). Expose in Dockerfile:

```dockerfile
EXPOSE 3000
```

## Health Check (optional in Dockerfile)

```dockerfile
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD wget -qO- http://localhost:${PORT}/health/live || exit 1
```

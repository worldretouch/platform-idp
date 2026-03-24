# Go API — Platform Service
# Build stage
FROM golang:1.22-alpine AS builder
ARG GIT_SHA=unknown
ARG SERVICE_NAME=go-api
ARG RUNTIME=go

WORKDIR /app
COPY go.mod go.sum ./
RUN go mod download
COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -o /app/server ./cmd/server

# Runtime stage
FROM alpine:3.19
ARG GIT_SHA=unknown
ARG SERVICE_NAME=go-api
ARG RUNTIME=go

LABEL org.opencontainers.image.revision="${GIT_SHA}"
LABEL platform.service="${SERVICE_NAME}"
LABEL platform.runtime="${RUNTIME}"

RUN adduser -D app
USER app
WORKDIR /app

COPY --from=builder /app/server .

ENV PORT=3000
EXPOSE 3000

CMD ["./server"]

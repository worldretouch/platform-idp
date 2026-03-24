# Go API — Platform Service
SERVICE_NAME ?= $(shell grep -E '^service_name:' service.yaml 2>/dev/null | awk '{print $$2}' || echo "go-api")
VERSION ?= $(shell git describe --tags --always 2>/dev/null || echo "dev")
IMAGE_REGISTRY ?= ghcr.io
IMAGE_REPO ?= $(IMAGE_REGISTRY)/myorg/$(SERVICE_NAME)
IMAGE_TAG ?= $(VERSION)

.PHONY: help deps run test lint build docker-build docker-push

help:
	@echo "Platform Service: $(SERVICE_NAME)"
	@echo "  deps, run, test, lint, build, docker-build, docker-push"

deps:
	go mod download
	go mod tidy

run:
	go run ./cmd/server

test:
	go test ./...

lint:
	go vet ./...
	@command -v staticcheck >/dev/null && staticcheck ./... || true

build:
	CGO_ENABLED=0 go build -o dist/server ./cmd/server

docker-build:
	docker build -t $(IMAGE_REPO):$(IMAGE_TAG) -t $(IMAGE_REPO):latest .

docker-push: docker-build
	docker push $(IMAGE_REPO):$(IMAGE_TAG)
	docker push $(IMAGE_REPO):latest

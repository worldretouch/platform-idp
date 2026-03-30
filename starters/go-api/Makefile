# Go API — Platform Service
SERVICE_NAME ?= $(shell grep -E '^service_name:' service.yaml 2>/dev/null | awk '{print $$2}' || echo "go-api")
VERSION ?= $(shell git describe --tags --always 2>/dev/null || echo "dev")
IMAGE_REGISTRY ?= ghcr.io
GITHUB_ORG ?= myorg
IMAGE_REPO ?= $(IMAGE_REGISTRY)/$(GITHUB_ORG)/$(SERVICE_NAME)
IMAGE_TAG ?= $(VERSION)

.PHONY: help init deps run test lint build docker-build docker-push

help:
	@echo "Platform Service: $(SERVICE_NAME)"
	@echo "  init, deps, run, test, lint, build, docker-build, docker-push"

init:
	@echo "Checking local prerequisites..."
	@command -v go >/dev/null || (echo "Missing go" && exit 1)
	@echo "Installing dependencies and running a smoke build..."
	go mod download
	go mod tidy
	CGO_ENABLED=0 go build -o /tmp/$(SERVICE_NAME)-smoke ./cmd/server
	@rm -f /tmp/$(SERVICE_NAME)-smoke
	@echo "Init complete. Next: make run"

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

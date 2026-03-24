# Platform Service Makefile — shared conventions
# Override in runtime starter as needed

SERVICE_NAME ?= $(shell grep -E '^service_name:' service.yaml 2>/dev/null | awk '{print $$2}' || echo "unknown")
VERSION ?= $(shell git describe --tags --always 2>/dev/null || echo "dev")
IMAGE_REGISTRY ?= ghcr.io
IMAGE_REPO ?= $(IMAGE_REGISTRY)/myorg/$(SERVICE_NAME)
IMAGE_TAG ?= $(VERSION)

.PHONY: help deps run test lint build docker-build docker-push clean

help:
	@echo "Platform Service: $(SERVICE_NAME)"
	@echo ""
	@echo "Targets:"
	@echo "  deps        Install dependencies"
	@echo "  run         Run service locally"
	@echo "  test        Run tests"
	@echo "  lint        Run linter"
	@echo "  build       Build artifact"
	@echo "  docker-build  Build container image"
	@echo "  docker-push   Push container image"
	@echo "  clean       Clean build artifacts"

deps:
	@echo "Override 'deps' in runtime starter"

run:
	@echo "Override 'run' in runtime starter"

test:
	@echo "Override 'test' in runtime starter"

lint:
	@echo "Override 'lint' in runtime starter"

build:
	@echo "Override 'build' in runtime starter"

docker-build:
	docker build -t $(IMAGE_REPO):$(IMAGE_TAG) -t $(IMAGE_REPO):latest .

docker-push: docker-build
	docker push $(IMAGE_REPO):$(IMAGE_TAG)
	docker push $(IMAGE_REPO):latest

clean:
	rm -rf dist/ build/ *.log

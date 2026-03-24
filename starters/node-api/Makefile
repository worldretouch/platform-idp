# Node.js API — Platform Service
SERVICE_NAME ?= $(shell grep -E '^service_name:' service.yaml 2>/dev/null | awk '{print $$2}' || echo "node-api")
IMAGE_REGISTRY ?= ghcr.io
IMAGE_REPO ?= $(IMAGE_REGISTRY)/myorg/$(SERVICE_NAME)

.PHONY: help init deps run test lint build docker-build docker-push

help:
	@echo "Platform Service: $(SERVICE_NAME)"
	@echo "  init, deps, run, test, lint, build, docker-build, docker-push"

init:
	@echo "Checking local prerequisites..."
	@command -v node >/dev/null || (echo "Missing node" && exit 1)
	@command -v npm >/dev/null || (echo "Missing npm" && exit 1)
	@echo "Installing dependencies and building..."
	npm ci
	npm run build
	@echo "Init complete. Next: make run"

deps:
	npm install

run:
	npm run dev

test:
	npm test

lint:
	npm run lint

build:
	npm run build

docker-build:
	docker build -t $(IMAGE_REPO):latest .

docker-push: docker-build
	docker push $(IMAGE_REPO):latest

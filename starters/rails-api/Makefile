# Rails API — Platform Service
SERVICE_NAME ?= $(shell grep -E '^service_name:' service.yaml 2>/dev/null | awk '{print $$2}' || echo "rails-api")
IMAGE_REGISTRY ?= ghcr.io
IMAGE_REPO ?= $(IMAGE_REGISTRY)/myorg/$(SERVICE_NAME)

.PHONY: help init deps run test lint build docker-build docker-push

help:
	@echo "Platform Service: $(SERVICE_NAME)"
	@echo "  init, deps, run, test, lint, build, docker-build, docker-push"

init:
	@echo "Checking local prerequisites..."
	@command -v ruby >/dev/null || (echo "Missing ruby" && exit 1)
	@command -v bundle >/dev/null || (echo "Missing bundle" && exit 1)
	@echo "Installing gems and running smoke checks..."
	bundle install
	bundle exec rails zeitwerk:check
	@echo "Init complete. Next: make run"

deps:
	bundle install

run:
	bundle exec rails server -p $${PORT:-3000}

test:
	bundle exec rspec

lint:
	bundle exec rubocop

build:
	@echo "Rails: use docker-build"

docker-build:
	docker build -t $(IMAGE_REPO):latest .

docker-push: docker-build
	docker push $(IMAGE_REPO):latest

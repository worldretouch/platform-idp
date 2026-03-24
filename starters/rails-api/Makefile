# Rails API — Platform Service
SERVICE_NAME ?= $(shell grep -E '^service_name:' service.yaml 2>/dev/null | awk '{print $$2}' || echo "rails-api")
IMAGE_REGISTRY ?= ghcr.io
IMAGE_REPO ?= $(IMAGE_REGISTRY)/myorg/$(SERVICE_NAME)

.PHONY: help deps run test lint build docker-build docker-push

help:
	@echo "Platform Service: $(SERVICE_NAME)"

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

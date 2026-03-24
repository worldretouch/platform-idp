# Python API — Platform Service
SERVICE_NAME ?= $(shell grep -E '^service_name:' service.yaml 2>/dev/null | awk '{print $$2}' || echo "python-api")
IMAGE_REGISTRY ?= ghcr.io
IMAGE_REPO ?= $(IMAGE_REGISTRY)/myorg/$(SERVICE_NAME)

.PHONY: help deps run test lint build docker-build docker-push

help:
	@echo "Platform Service: $(SERVICE_NAME)"

deps:
	pip install -r requirements-dev.txt

run:
	uvicorn app.main:app --reload --host 0.0.0.0 --port $${PORT:-3000}

test:
	pytest

lint:
	ruff check app/

build:
	@echo "Python: use docker-build"

docker-build:
	docker build -t $(IMAGE_REPO):latest .

docker-push: docker-build
	docker push $(IMAGE_REPO):latest

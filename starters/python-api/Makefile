# Python API — Platform Service
SERVICE_NAME ?= $(shell grep -E '^service_name:' service.yaml 2>/dev/null | awk '{print $$2}' || echo "python-api")
IMAGE_REGISTRY ?= ghcr.io
GITHUB_ORG ?= myorg
IMAGE_REPO ?= $(IMAGE_REGISTRY)/$(GITHUB_ORG)/$(SERVICE_NAME)

.PHONY: help init deps run test lint build docker-build docker-push

help:
	@echo "Platform Service: $(SERVICE_NAME)"
	@echo "  init, deps, run, test, lint, build, docker-build, docker-push"

init:
	@echo "Checking local prerequisites..."
	@command -v python3 >/dev/null || (echo "Missing python3" && exit 1)
	@command -v pip >/dev/null || (echo "Missing pip" && exit 1)
	@echo "Installing dependencies and running smoke checks..."
	pip install -r requirements-dev.txt
	python3 -m py_compile app/main.py
	@echo "Init complete. Next: make run"

deps:
	pip install -r requirements-dev.txt

run:
	uvicorn app.main:app --reload --host 0.0.0.0 --port $${PORT:-3000}

test:
	PYTHONPATH=. pytest

lint:
	ruff check app/

build:
	@echo "Python: use docker-build"

docker-build:
	docker build -t $(IMAGE_REPO):latest .

docker-push: docker-build
	docker push $(IMAGE_REPO):latest

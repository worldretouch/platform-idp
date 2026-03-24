# Platform IDP — Top-level Makefile
# Scaffold a new service from a runtime starter

.PHONY: scaffold help

help:
	@echo "Platform IDP"
	@echo ""
	@echo "  make scaffold RUNTIME=go SERVICE_NAME=my-service OUTPUT_DIR=../my-service"
	@echo ""
	@echo "RUNTIME: rails | go | node | python"
	@echo "SERVICE_NAME: kebab-case service name (e.g. orders-api)"
	@echo "OUTPUT_DIR: where to create the new service (default: ../<SERVICE_NAME>)"

scaffold:
	@RUNTIME=$(RUNTIME) SERVICE_NAME=$(SERVICE_NAME) OUTPUT_DIR=$(or $(OUTPUT_DIR),../$(SERVICE_NAME)) \
	$(MAKE) _scaffold

_scaffold:
	@if [ -z "$(RUNTIME)" ] || [ -z "$(SERVICE_NAME)" ]; then \
		echo "Usage: make scaffold RUNTIME=<rails|go|node|python> SERVICE_NAME=<name>"; exit 1; \
	fi
	@mkdir -p $(OUTPUT_DIR)
	@cp -r base-template/* $(OUTPUT_DIR)/ 2>/dev/null || true
	@cp -r starters/$(RUNTIME)-api/* $(OUTPUT_DIR)/
	@echo "Scaffolded $(SERVICE_NAME) with $(RUNTIME) to $(OUTPUT_DIR)"
	@echo "Next: cd $(OUTPUT_DIR) && make deps && make run"

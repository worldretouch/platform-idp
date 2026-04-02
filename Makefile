# Platform IDP — Top-level Makefile
# Scaffold a new service repo and its GitOps app/values

.PHONY: scaffold scaffold-env help
TEMPLATE_VERSION ?= v0.2.0
# Used when rendering .github/workflows/ci.yml (reusable workflow from platform-idp)
GITHUB_ORG ?= worldretouch
PLATFORM_REF ?= main

help:
	@echo "Platform IDP"
	@echo ""
	@echo "  make scaffold RUNTIME=go SERVICE_NAME=my-service OUTPUT_DIR=../my-service"
	@echo "  make scaffold ... GITHUB_ORG=myorg PLATFORM_REF=main   # optional: reusable CI target"
	@echo "  make scaffold-env SERVICE_NAME=my-service ENV_REPO_DIR=../platform-env"
	@echo ""
	@echo "RUNTIME: rails | go | node | python"
	@echo "SERVICE_NAME: kebab-case service name (e.g. orders-api)"
	@echo "OUTPUT_DIR: where to create the new service (default: ../<SERVICE_NAME>)"
	@echo "ENV_REPO_DIR: path to cloned platform-env repo (default: ../platform-env)"

scaffold:
	@RUNTIME=$(RUNTIME) SERVICE_NAME=$(SERVICE_NAME) OUTPUT_DIR=$(or $(OUTPUT_DIR),../$(SERVICE_NAME)) \
	$(MAKE) _scaffold

_scaffold:
	@if [ -z "$(RUNTIME)" ] || [ -z "$(SERVICE_NAME)" ]; then \
		echo "Usage: make scaffold RUNTIME=<rails|go|node|python> SERVICE_NAME=<name>"; exit 1; \
	fi
	@mkdir -p $(OUTPUT_DIR)
	@cp -r base-template/. $(OUTPUT_DIR)/ 2>/dev/null || true
	@cp -r starters/$(RUNTIME)-api/. $(OUTPUT_DIR)/
	@if [ -f "$(OUTPUT_DIR)/service.yaml" ]; then \
		awk -v name="$(SERVICE_NAME)" -v runtime="$(RUNTIME)" \
		'BEGIN{updated_name=0; updated_runtime=0} \
		/^service_name:/ {print "service_name: " name; updated_name=1; next} \
		/^runtime:/ {print "runtime: " runtime; updated_runtime=1; next} \
		{print} \
		END {if (!updated_name) print "service_name: " name; if (!updated_runtime) print "runtime: " runtime}' \
		"$(OUTPUT_DIR)/service.yaml" > "$(OUTPUT_DIR)/service.yaml.tmp" && mv "$(OUTPUT_DIR)/service.yaml.tmp" "$(OUTPUT_DIR)/service.yaml"; \
	fi
	@printf "platform_template_version: %s\nruntime_template: %s-api\n" "$(TEMPLATE_VERSION)" "$(RUNTIME)" > "$(OUTPUT_DIR)/.platform-template-version"
	@if [ -f "$(OUTPUT_DIR)/.github/workflows/ci.yml" ]; then \
		sed -i.bak \
			-e "s|__SERVICE_NAME__|$(SERVICE_NAME)|g" \
			-e "s|__RUNTIME__|$(RUNTIME)|g" \
			-e "s|__GITHUB_ORG__|$(GITHUB_ORG)|g" \
			-e "s|__PLATFORM_REF__|$(PLATFORM_REF)|g" \
			"$(OUTPUT_DIR)/.github/workflows/ci.yml" && rm -f "$(OUTPUT_DIR)/.github/workflows/ci.yml.bak"; \
	fi
	@echo "Scaffolded $(SERVICE_NAME) with $(RUNTIME) to $(OUTPUT_DIR)"
	@echo "Next: cd $(OUTPUT_DIR) && make init && make run"

# Scaffold GitOps app + values for a new service in the env repo.
# Example:
#   make scaffold-env SERVICE_NAME=payments-api ENV_REPO_DIR=../platform-env
#
ENV_REPO_DIR ?= ../platform-env

scaffold-env:
	@if [ -z "$(SERVICE_NAME)" ]; then \
		echo "Usage: make scaffold-env SERVICE_NAME=<name> [ENV_REPO_DIR=../platform-env]"; exit 1; \
	fi
	@if [ ! -d "$(ENV_REPO_DIR)" ]; then \
		echo "ENV_REPO_DIR not found: $(ENV_REPO_DIR). Clone your platform-env repo there or override ENV_REPO_DIR."; \
		exit 1; \
	fi
	@for env in dev staging prod; do \
		if [ ! -f "$(ENV_REPO_DIR)/environments/$$env/apps/orders-api.yaml" ] || \
		   [ ! -f "$(ENV_REPO_DIR)/environments/$$env/values/orders-api.values.yaml" ]; then \
			echo "Missing orders-api skeleton in $$env. Run bootstrap-env-repo first."; \
			exit 1; \
		fi; \
	done
	@echo "Scaffolding GitOps app/values for $(SERVICE_NAME) into $(ENV_REPO_DIR)..."
	@for env in dev staging prod; do \
		app_src="$(ENV_REPO_DIR)/environments/$$env/apps/orders-api.yaml"; \
		val_src="$(ENV_REPO_DIR)/environments/$$env/values/orders-api.values.yaml"; \
		app_dst="$(ENV_REPO_DIR)/environments/$$env/apps/$(SERVICE_NAME).yaml"; \
		val_dst="$(ENV_REPO_DIR)/environments/$$env/values/$(SERVICE_NAME).values.yaml"; \
		cp "$$app_src" "$$app_dst"; \
		cp "$$val_src" "$$val_dst"; \
		sed -i.bak "s/orders-api/$(SERVICE_NAME)/g" "$$app_dst" "$$val_dst"; \
		rm -f "$$app_dst.bak" "$$val_dst.bak"; \
	done
	@echo "Scaffolded GitOps app/values for $(SERVICE_NAME) in $(ENV_REPO_DIR)."
	@echo "Next: commit and push changes in $(ENV_REPO_DIR), then let Argo CD sync new Applications."

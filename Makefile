# Makefile
ENV_FILE ?= .env

# Reusable check snippet
CHECK_ENV = \
	@if [ ! -f $(ENV_FILE) ]; then \
		echo "❌ $(ENV_FILE) not found. Please create it first."; \
		exit 1; \
	fi

build:
	$(CHECK_ENV)
	@set -a; \
	. $(CURDIR)/$(ENV_FILE); \
	set +a; \
	echo "🚀 Building images..."; \
	skaffold build --default-repo="$$IMAGE_REGISTRY" --tag="$$IMAGE_TAG" --push

render:
	$(CHECK_ENV)
	@set -a; \
	. $(CURDIR)/$(ENV_FILE); \
	set +a; \
	echo "📦 Rendering manifests..."; \
	skaffold render --default-repo="$$IMAGE_REGISTRY" --tag="$$IMAGE_TAG" | envsubst

deploy:
	$(CHECK_ENV)
	@set -a; \
	. $(CURDIR)/$(ENV_FILE); \
	set +a; \
	echo "📦 Deploying manifests..."; \
	skaffold render --default-repo="$$IMAGE_REGISTRY" --tag="$$IMAGE_TAG" | envsubst | kubectl apply -f -

deploy-openshift: deploy
	@echo "🔼 Applying OpenShift-specific Routes..."
	kubectl apply -f openshift/routes.yaml -n keventmesh
	@echo "✅ OpenShift deployment complete."

.PHONY: deploy-openshift

clean:
	@echo "🧹 Cleaning up..."; \
	skaffold delete

.PHONY: build deploy

# HYDRA Development NATS Environment
# Simplified version for reliable localhost:4222 NATS

.PHONY: help start stop restart status logs clean test info

# Default target
help: ## Show available commands
	@echo "🚀 HYDRA Development NATS Environment"
	@echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-12s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

start: ## Start NATS server
	@echo "🚀 Starting HYDRA Development NATS..."
	@mkdir -p nats/logs
	@docker compose up -d nats
	@echo "⏳ Waiting for NATS..."
	@for i in {1..30}; do \
		if curl -sf http://localhost:8222/healthz >/dev/null 2>&1; then \
			echo "✅ NATS ready at localhost:4222"; \
			echo "📊 Monitoring at http://localhost:8222"; \
			echo "👤 User: app-limited"; \
			echo "🔑 Pass: dev-password-change-in-production"; \
			exit 0; \
		fi; \
		sleep 1; \
	done; \
	echo "❌ NATS failed to start - check logs with 'make logs'"

stop: ## Stop NATS server
	@echo "🛑 Stopping NATS..."
	@docker compose down
	@echo "✅ Stopped"

restart: stop start ## Restart NATS server

status: ## Show NATS status
	@echo "📊 NATS Status:"
	@if curl -sf http://localhost:8222/healthz >/dev/null 2>&1; then \
		echo "✅ Running on localhost:4222"; \
	else \
		echo "❌ Not running"; \
	fi
	@docker compose ps

logs: ## Show NATS logs
	@docker compose logs -f nats

test: ## Test NATS connection
	@echo "🧪 Testing NATS connection..."
	@if curl -sf http://localhost:8222/varz >/dev/null 2>&1; then \
		echo "✅ NATS responding on localhost:4222"; \
		echo "✅ Monitoring available on localhost:8222"; \
	else \
		echo "❌ NATS not responding - run 'make start'"; \
	fi

info: ## Show connection details
	@echo "🎯 HYDRA Development NATS Info"
	@echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
	@echo "NATS URL:    nats://localhost:4222"
	@echo "Monitor:     http://localhost:8222"
	@echo "Health:      http://localhost:8222/healthz"
	@echo ""
	@echo "Credentials:"
	@echo "  User:      app-limited"
	@echo "  Password:  dev-password-change-in-production"

clean: ## Stop and remove everything
	@echo "🧹 Cleaning up..."
	@docker compose down -v --remove-orphans
	@echo "✅ Clean"

# Quick aliases
up: start
down: stop

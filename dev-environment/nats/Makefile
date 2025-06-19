# HYDRA Development NATS Environment
# Provides production-parity localhost:4222 for development

.PHONY: help start stop restart status test logs clean monitor setup install health install-docker quick-start

# Default target
help: ## Show this help message
	@echo "🚀 HYDRA Development NATS Environment"
	@echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
	@echo "Provides localhost:4222 NATS that matches HYDRA production"
	@echo ""
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-15s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

install-docker: ## Install Docker and prerequisites
	@echo "🚀 Installing Docker and prerequisites for HYDRA development..."
	@if [ "$(uname)" = "Darwin" ]; then \
		echo "📦 Installing for macOS..."; \
		if ! command -v brew >/dev/null 2>&1; then \
			echo "Installing Homebrew..."; \
			/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"; \
		fi; \
		if ! command -v docker >/dev/null 2>&1; then \
			echo "Installing Docker Desktop..."; \
			brew install --cask docker; \
			echo "⚠️  Please start Docker Desktop manually and run 'make quick-start' again"; \
			exit 1; \
		fi; \
		brew install git make curl jq 2>/dev/null || true; \
	elif [ -f /etc/debian_version ]; then \
		echo "📦 Installing for Ubuntu/Debian..."; \
		sudo apt update; \
		if ! command -v docker >/dev/null 2>&1; then \
			sudo apt install -y docker.io git make curl jq; \
			sudo systemctl start docker; \
			sudo systemctl enable docker; \
			sudo usermod -aG docker $USER; \
			echo "⚠️  Please log out and back in, then run 'make quick-start'"; \
			exit 1; \
		fi; \
	elif [ -f /etc/redhat-release ]; then \
		echo "📦 Installing for Red Hat/CentOS/Fedora..."; \
		if command -v dnf >/dev/null 2>&1; then \
			sudo dnf install -y docker git make curl jq; \
		else \
			sudo yum install -y docker git make curl jq; \
		fi; \
		sudo systemctl start docker; \
		sudo systemctl enable docker; \
		sudo usermod -aG docker $USER; \
		echo "⚠️  Please log out and back in, then run 'make quick-start'"; \
		exit 1; \
	else \
		echo "❌ Unsupported OS. Please install Docker manually"; \
		exit 1; \
	fi
	@echo "✅ Prerequisites installed successfully!"

quick-start: ## One-command setup: install prerequisites and start HYDRA environment
	@echo "🚀 HYDRA Development Environment - Quick Start"
	@echo "=============================================="
	@echo ""
	@if ! docker info >/dev/null 2>&1; then \
		echo "Docker not found or not running. Installing prerequisites..."; \
		$(MAKE) install-docker; \
	fi
	@echo "🎯 Starting HYDRA development environment..."
	@$(MAKE) start
	@echo ""
	@echo "🎉 SUCCESS! HYDRA Development Environment is Ready!"
	@echo "=================================================="
	@echo ""
	@echo "🎯 NATS Server:     nats://localhost:4222"
	@echo "📊 Monitoring:      http://localhost:8222"
	@echo "🩺 Health Check:    http://localhost:8222/healthz"
	@echo ""
	@echo "👤 User:            app-limited"
	@echo "🔑 Password:        dev-password-change-in-production"
	@echo ""
	@echo "Next steps:"
	@echo "  make test          # Test connectivity"
	@echo "  make info          # Show connection details"
	@echo "  make install-cli   # Install NATS CLI (optional)"
	@echo ""
	@echo "🎯 Your applications can now connect to localhost:4222"
	@echo "   This works exactly the same on HYDRA production units!"

setup: ## Initial setup - prepare environment (use quick-start for full setup)
	@echo "📥 Setting up HYDRA development environment..."
	@if [ ! -f docker-compose.yml ]; then \
		echo "❌ docker-compose.yml not found. Please ensure you're in the hydra-public/dev-environment/nats directory"; \
		exit 1; \
	fi
	@if [ ! -f nats/nats-server.conf ]; then \
		echo "❌ nats/nats-server.conf not found. Please ensure the config file exists"; \
		exit 1; \
	fi
	@echo "🔧 Creating logs directory with proper permissions..."
	@mkdir -p nats/logs
	@chown -R $(shell id -u):$(shell id -g) nats/logs 2>/dev/null || \
		sudo chown -R $(shell id -u):$(shell id -g) nats/logs || \
		echo "⚠️  Could not fix permissions for nats/logs - you may need to run: sudo chown -R $USER:$USER nats/logs"
	@echo "✅ Setup complete"
	@echo "💡 Use 'make quick-start' for automatic Docker installation and startup"

install: setup ## Install (alias for setup)

start: ## Start HYDRA development NATS server
	@echo "🚀 Starting HYDRA Development NATS Environment..."
	@if ! docker info > /dev/null 2>&1; then \
		echo "❌ Docker is not running. Please start Docker first."; \
		exit 1; \
	fi
	@echo "🔧 Ensuring proper setup..."
	@$(MAKE) setup
	@echo "📡 Starting NATS server..."
	@docker compose up -d nats
	@echo "⏳ Waiting for NATS to be ready..."
	@timeout=30; \
	while [ $timeout -gt 0 ]; do \
		if curl -f http://localhost:8222/healthz > /dev/null 2>&1; then \
			echo "✅ NATS is ready on localhost:4222"; \
			break; \
		fi; \
		sleep 1; \
		timeout=$((timeout-1)); \
	done; \
	if [ $timeout -eq 0 ]; then \
		echo "❌ NATS failed to start properly"; \
		echo "📋 Container logs:"; \
		docker compose logs nats --tail=20; \
		echo ""; \
		echo "🔍 Container status:"; \
		docker compose ps; \
		echo ""; \
		echo "💡 Troubleshooting tips:"; \
		echo "   1. Check config file: cat nats/nats-server.conf"; \
		echo "   2. Check permissions: ls -la nats/"; \
		echo "   3. Try basic NATS: docker run --rm -p 4222:4222 nats:2.11-alpine"; \
		echo "   4. Check ports: netstat -an | grep ':4222\\|:8222'"; \
		exit 1; \
	fi
	@echo ""
	@echo "🎯 HYDRA Development Environment Ready!"
	@echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
	@echo "NATS Client URL:    nats://localhost:4222"
	@echo "NATS Monitoring:    http://localhost:8222"
	@echo "Health Check:       http://localhost:8222/healthz"
	@echo ""
	@echo "Credentials:"
	@echo "  User: app-limited"
	@echo "  Pass: dev-password-change-in-production"
	@echo ""
	@echo "🎯 Your application can now connect to localhost:4222"
	@echo "   This matches exactly how it works on HYDRA units!"

stop: ## Stop HYDRA development NATS server
	@echo "🛑 Stopping HYDRA Development NATS..."
	@docker compose down
	@echo "✅ NATS stopped"

restart: stop start ## Restart NATS server

status: ## Show status of HYDRA development environment
	@echo "📊 HYDRA Development Environment Status"
	@echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
	@if docker compose ps | grep -q "hydra-dev-nats.*Up"; then \
		echo "✅ NATS Server: Running"; \
		if curl -f http://localhost:8222/healthz > /dev/null 2>&1; then \
			echo "✅ Health Check: Passing"; \
		else \
			echo "❌ Health Check: Failing"; \
		fi; \
	else \
		echo "❌ NATS Server: Not Running"; \
	fi; \
	echo ""; \
	docker compose ps

health: ## Check NATS health and connectivity
	@echo "🩺 HYDRA Development NATS Health Check"
	@echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
	@if ! curl -f http://localhost:8222/varz > /dev/null 2>&1; then \
		echo "❌ NATS server not responding on localhost:8222"; \
		echo "💡 Run: make start"; \
		exit 1; \
	fi
	@echo "✅ NATS server is running on localhost:4222"
	@echo "✅ HTTP monitoring available on localhost:8222"
	@if command -v nats >/dev/null 2>&1; then \
		echo "📡 Testing publish/subscribe..."; \
		nats --server localhost:4222 --user app-limited --password dev-password-change-in-production \
			pub app.test.health "Health check from make" > /dev/null 2>&1 && \
			echo "✅ Message publishing works" || \
			echo "❌ Message publishing failed"; \
	else \
		echo "💡 Install nats CLI for advanced testing:"; \
		echo "   go install github.com/nats-io/natscli/nats@latest"; \
	fi

test: health ## Test NATS connection and functionality
	@echo ""
	@echo "🧪 Running Connection Tests..."
	@if command -v nats >/dev/null 2>&1; then \
		echo "📊 NATS Server Info:"; \
		nats --server localhost:4222 --user app-limited --password dev-password-change-in-production \
			server info 2>/dev/null || echo "❌ Failed to get server info"; \
	fi
	@echo ""
	@echo "🎯 Development environment ready for your application!"

logs: ## Show NATS server logs
	@echo "📋 HYDRA Development NATS Logs"
	@echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
	@docker compose logs -f nats

monitor: ## Start monitoring dashboard
	@echo "📊 Starting HYDRA Development Monitoring..."
	@docker compose --profile monitoring up -d
	@echo "✅ Monitoring dashboard available at: http://localhost:7777"
	@echo "✅ NATS monitoring at: http://localhost:8222"

clean: stop ## Stop and remove all containers and volumes
	@echo "🧹 Cleaning up HYDRA development environment..."
	@docker compose down -v --remove-orphans
	@docker compose --profile monitoring down -v --remove-orphans 2>/dev/null || true
	@echo "✅ Cleanup complete"

# Development workflow targets
dev-start: start ## Start development environment (alias for start)

dev-test: start test ## Start environment and run tests

dev-stop: stop ## Stop development environment (alias for stop)

# Quick access to common info
info: ## Show connection information
	@echo "🎯 HYDRA Development Environment Info"
	@echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
	@echo "NATS URL:     nats://localhost:4222"
	@echo "Monitor:      http://localhost:8222"
	@echo "Health:       http://localhost:8222/healthz"
	@echo ""
	@echo "Authentication:"
	@echo "  User:       app-limited"
	@echo "  Password:   dev-password-change-in-production"
	@echo ""
	@echo "Subject Namespace:"
	@echo "  Your App:   app.yourapp.*"
	@echo "  NimsForest: app.nimsforest.*"
	@echo "  Telemetry:  telemetry.*"

# Advanced targets
pull: ## Pull latest NATS images
	@echo "📥 Pulling latest NATS images..."
	@docker compose pull
	@echo "✅ Images updated"

update: pull restart ## Update NATS images and restart

# Development debugging
debug: ## Show debug information
	@echo "🔍 HYDRA Development Debug Information"
	@echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
	@echo "Docker Status:"
	@docker --version
	@docker info --format "  Version: {{.ServerVersion}}"
	@echo ""
	@echo "Container Status:"
	@docker compose ps
	@echo ""
	@echo "Network Status:"
	@netstat -an | grep ":4222\|:6222\|:8222" || echo "  No NATS ports found"
	@echo ""
	@echo "Environment Files:"
	@ls -la nats/ 2>/dev/null || echo "  nats/ directory not found"
	@echo ""
	@echo "Recent Container Logs:"
	@docker compose logs nats --tail=10 2>/dev/null || echo "  No container logs available"

troubleshoot: ## Run comprehensive troubleshooting
	@echo "🔧 HYDRA Development Environment Troubleshooting"
	@echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
	@echo ""
	@echo "1. Checking file structure..."
	@if [ -f docker-compose.yml ]; then \
		echo "✅ docker-compose.yml exists"; \
	else \
		echo "❌ docker-compose.yml missing"; \
	fi
	@if [ -f nats/nats-server.conf ]; then \
		echo "✅ nats-server.conf exists"; \
	else \
		echo "❌ nats-server.conf missing"; \
	fi
	@if [ -d nats/logs ]; then \
		echo "✅ logs directory exists"; \
		ls -la nats/logs/; \
	else \
		echo "❌ logs directory missing"; \
	fi
	@echo ""
	@echo "2. Checking Docker..."
	@if docker info >/dev/null 2>&1; then \
		echo "✅ Docker is running"; \
		docker --version; \
	else \
		echo "❌ Docker is not running or accessible"; \
	fi
	@echo ""
	@echo "3. Checking ports..."
	@if netstat -an 2>/dev/null | grep -q ":4222"; then \
		echo "⚠️  Port 4222 is already in use:"; \
		netstat -an | grep ":4222"; \
	else \
		echo "✅ Port 4222 is available"; \
	fi
	@if netstat -an 2>/dev/null | grep -q ":8222"; then \
		echo "⚠️  Port 8222 is already in use:"; \
		netstat -an | grep ":8222"; \
	else \
		echo "✅ Port 8222 is available"; \
	fi
	@echo ""
	@echo "4. Testing basic NATS container..."
	@echo "Running basic NATS test (5 seconds)..."
	@timeout 5s docker run --rm -p 14222:4222 nats:2.11-alpine > /dev/null 2>&1 && \
		echo "✅ Basic NATS container works" || \
		echo "❌ Basic NATS container failed"
	@echo ""
	@echo "5. Checking NATS config syntax..."
	@docker run --rm -v "./nats/nats-server.conf:/tmp/test.conf:ro" nats:2.11-alpine -t /tmp/test.conf > /dev/null 2>&1 && \
		echo "✅ NATS config syntax is valid" || \
		echo "❌ NATS config has syntax errors"

# Help with NATS CLI installation
install-cli: ## Install NATS CLI tool
	@echo "📦 Installing NATS CLI tool..."
	@if command -v go >/dev/null 2>&1; then \
		go install github.com/nats-io/natscli/nats@latest; \
		echo "✅ NATS CLI installed successfully"; \
		echo "💡 Make sure $(go env GOPATH)/bin is in your PATH"; \
	else \
		echo "❌ Go not found. Please install Go first:"; \
		echo "   https://golang.org/doc/install"; \
	fi

fix-permissions: ## Fix common permission issues
	@echo "🔧 Fixing HYDRA development environment permissions..."
	@if [ -d nats/logs ]; then \
		echo "📁 Fixing logs directory permissions..."; \
		sudo chown -R $(shell id -u):$(shell id -g) nats/logs 2>/dev/null || \
			echo "⚠️  Could not change ownership. You may need to run: sudo chown -R $USER:$USER nats/logs"; \
		chmod -R 755 nats/logs 2>/dev/null || echo "⚠️  Could not change permissions"; \
		echo "✅ Permissions updated"; \
	else \
		echo "📁 Creating logs directory..."; \
		mkdir -p nats/logs; \
		chown $(shell id -u):$(shell id -g) nats/logs 2>/dev/null || true; \
		chmod 755 nats/logs 2>/dev/null || true; \
		echo "✅ Logs directory created"; \
	fi

# Quick fixes for common issues
reset: clean setup ## Reset environment (stop, clean, and setup again)

doctor: troubleshoot ## Alias for troubleshoot

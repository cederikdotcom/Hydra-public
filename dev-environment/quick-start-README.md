# HYDRA Development Environment - Fresh Machine Setup (Cross-Platform)
# Shell script installs make, then uses make for NATS management

# ============================================
# ONE-COMMAND SETUP (All Platforms)
# ============================================

# Clone and start (auto-installs Docker + make, then uses make)
git clone https://github.com/hydrahardware/hydra-public.git
cd hydra-public/dev-environment
./quick-start.sh

# That's it! Auto-installs Docker + make, then starts localhost:4222 NATS! 🎉

# ============================================
# WHAT THE QUICK-START DOES
# ============================================

# 1. Detects your OS (Windows/macOS/Linux)
# 2. Auto-installs Docker + make + prerequisites
# 3. Navigates to nats/ directory
# 4. Runs: make start
# 5. Shows you management commands using make

# ============================================
# DAILY WORKFLOW (After Setup)
# ============================================

# Navigate to nats directory
cd hydra-public/dev-environment/nats

# Use professional make commands
make help             # Show all available commands
make start            # Start HYDRA environment
make stop             # Stop environment
make status           # Check if running
make test             # Test connectivity
make logs             # View logs
make restart          # Restart NATS
make clean            # Clean up everything
make info             # Show connection details

# ============================================
# PLATFORM SUPPORT
# ============================================

# Windows (multiple options):
#   - Git Bash (recommended): Includes make, full compatibility
#   - WSL: Full Linux experience with make
#   - PowerShell: Auto-installs make via chocolatey

# macOS:
#   - Auto-installs Homebrew, Docker Desktop, and make
#   - Full Terminal/iTerm2 compatibility

# Linux:
#   - Auto-installs Docker and make via package manager
#   - Works on Ubuntu, Debian, CentOS, Fedora

# ============================================
# TEST YOUR CONNECTION
# ============================================

# After make start, test with:
make test

# Or manually test:
curl http://localhost:8222/healthz

# Install NATS CLI for advanced testing:
make install-cli
nats --server localhost:4222 --user app-limited --password dev-password-change-in-production server info

# ============================================
# TEST APPLICATION EXAMPLE
# ============================================

# Create a simple test (works on all platforms)
cat > test-app.go << 'EOF'
package main

import (
    "fmt"
    "log"
    "github.com/nats-io/nats.go"
)

func main() {
    // This exact code works on HYDRA units too!
    nc, err := nats.Connect("nats://localhost:4222",
        nats.UserInfo("app-limited", "dev-password-change-in-production"))
    if err != nil {
        log.Fatal(err)
    }
    defer nc.Close()

    fmt.Println("✅ Connected to HYDRA development NATS!")
    fmt.Println("🎯 This exact code works on HYDRA units!")
}
EOF

# Run the test (requires Go)
go mod init test && go get github.com/nats-io/nats.go && go run test-app.go

# ============================================
# SUCCESS! 🎉
# ============================================

# You now have:
# ✅ localhost:4222 NATS server (production-identical)
# ✅ Monitoring at http://localhost:8222  
# ✅ Professional make interface for management
# ✅ Cross-platform support (Windows/macOS/Linux)
# ✅ Zero config changes needed for HYDRA deployment

# Your development environment matches HYDRA units exactly!

# ============================================
# DEPLOYMENT TO HYDRA UNITS
# ============================================

# Your exact code works on HYDRA units:
# 1. Same localhost:4222 connection
# 2. Same authentication patterns
# 3. Same subject namespaces
# 4. Zero configuration changes needed

# Deploy workflow:
# scp myapp hydra-unit:/opt/myapp/
# ssh hydra-unit "./myapp"  # Connects to localhost:4222 on HYDRA too!

# ============================================
# ADVANTAGES OF THIS APPROACH
# ============================================

# Shell script for setup:
# ✅ Works everywhere (no make dependency for initial setup)
# ✅ Auto-installs make as prerequisite
# ✅ Cross-platform Docker installation
# ✅ One-command universal setup

# Make for management:
# ✅ Professional developer experience
# ✅ Self-documenting commands (make help)
# ✅ Consistent interface across platforms
# ✅ Easy integration with IDEs and CI/CD

#!/bin/bash
# HYDRA Development Environment - Quick Start (Cross-Platform)
# Works on Windows (Git Bash/WSL), macOS, and Linux

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

echo -e "${BLUE}"
echo "🚀 HYDRA Development Environment - Quick Start"
echo "=============================================="
echo -e "${NC}"

# Detect operating system
detect_os() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        echo "macos"
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        if [ -f /etc/debian_version ]; then
            echo "debian"
        elif [ -f /etc/redhat-release ]; then
            echo "redhat"
        else
            echo "linux"
        fi
    elif [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" ]] || grep -qi microsoft /proc/version 2>/dev/null; then
        echo "windows"
    else
        echo "unknown"
    fi
}

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check if Docker is running
docker_running() {
    docker info >/dev/null 2>&1
}

OS=$(detect_os)
echo -e "${BLUE}Detected OS: $OS${NC}"

# Check if we're in the right directory
if [[ ! -d "nats" ]]; then
    echo -e "${RED}❌ Please run this from the dev-environment directory${NC}"
    echo "   cd hydra-public/dev-environment"
    echo "   ./quick-start.sh"
    exit 1
fi

echo ""
echo -e "${CYAN}Step 1: Checking prerequisites...${NC}"

# Check for Docker
if ! command_exists docker; then
    echo -e "${YELLOW}⚠️  Docker not found. Installing...${NC}"
    
    case $OS in
        "macos")
            echo -e "${BLUE}📦 Installing for macOS...${NC}"
            if ! command_exists brew; then
                echo "Installing Homebrew..."
                /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
                
                # Add Homebrew to PATH for current session
                if [[ -f "/opt/homebrew/bin/brew" ]]; then
                    export PATH="/opt/homebrew/bin:$PATH"
                fi
            fi
            echo "Installing Docker Desktop..."
            brew install --cask docker
            echo "Installing make..."
            brew install make
            echo -e "${YELLOW}⚠️  Please start Docker Desktop manually and run this script again${NC}"
            exit 1
            ;;
            
        "debian")
            echo -e "${BLUE}📦 Installing for Ubuntu/Debian...${NC}"
            sudo apt update
            sudo apt install -y docker.io docker-compose git curl jq make
            sudo systemctl start docker
            sudo systemctl enable docker
            sudo usermod -aG docker $USER
            echo -e "${YELLOW}⚠️  Please log out and back in (or run 'newgrp docker') then run this script again${NC}"
            exit 1
            ;;
            
        "redhat")
            echo -e "${BLUE}📦 Installing for Red Hat/CentOS/Fedora...${NC}"
            if command_exists dnf; then
                sudo dnf install -y docker docker-compose git curl jq make
            else
                sudo yum install -y docker docker-compose git curl jq make
            fi
            sudo systemctl start docker
            sudo systemctl enable docker
            sudo usermod -aG docker $USER
            echo -e "${YELLOW}⚠️  Please log out and back in (or run 'newgrp docker') then run this script again${NC}"
            exit 1
            ;;
            
        "windows")
            echo -e "${BLUE}🪟 Windows detected${NC}"
            echo -e "${YELLOW}Please install Docker Desktop for Windows:${NC}"
            echo "  1. Download: https://desktop.docker.com/win/main/amd64/Docker%20Desktop%20Installer.exe"
            echo "  2. Install and start Docker Desktop"
            echo "  3. Install make: choco install make (or use Git Bash which includes make)"
            echo "  4. Run this script again"
            exit 1
            ;;
            
        *)
            echo -e "${RED}❌ Unsupported OS: $OS${NC}"
            echo "Please install Docker and make manually:"
            echo "  Windows: https://desktop.docker.com/win/main/amd64/Docker%20Desktop%20Installer.exe + choco install make"
            echo "  macOS: https://desktop.docker.com/mac/main/amd64/Docker.dmg + brew install make"
            echo "  Linux: Install docker.io and make packages"
            exit 1
            ;;
    esac
fi

# Check if make is installed
if ! command_exists make; then
    echo -e "${YELLOW}⚠️  make not found. Installing...${NC}"
    
    case $OS in
        "macos")
            if ! command_exists brew; then
                echo "Installing Homebrew first..."
                /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
                # Add Homebrew to PATH for current session
                if [[ -f "/opt/homebrew/bin/brew" ]]; then
                    export PATH="/opt/homebrew/bin:$PATH"
                fi
            fi
            brew install make
            ;;
        "debian")
            sudo apt install -y make
            ;;
        "redhat")
            if command_exists dnf; then
                sudo dnf install -y make
            else
                sudo yum install -y make
            fi
            ;;
        "windows")
            echo -e "${YELLOW}For Windows:${NC}"
            echo "  Git Bash: make is included"
            echo "  PowerShell: choco install make"
            echo "  WSL: sudo apt install make"
            ;;
        *)
            echo -e "${RED}❌ Please install make manually${NC}"
            exit 1
            ;;
    esac
fi

echo -e "${GREEN}✅ make is available${NC}"

# Check if Docker is running
if ! docker_running; then
    echo -e "${YELLOW}⚠️  Docker is installed but not running${NC}"
    case $OS in
        "macos"|"windows")
            echo "Please start Docker Desktop and run this script again"
            ;;
        *)
            echo "Please start Docker: sudo systemctl start docker"
            ;;
    esac
    exit 1
fi

echo -e "${GREEN}✅ Docker is running${NC}"

# Check for docker-compose or docker compose
if ! command_exists docker-compose; then
    # Try docker compose (newer version)
    if ! docker compose version >/dev/null 2>&1; then
        echo -e "${YELLOW}⚠️  docker compose not found, installing...${NC}"
        case $OS in
            "macos")
                brew install docker-compose
                ;;
            "debian")
                sudo apt install -y docker-compose-plugin
                ;;
            "redhat")
                if command_exists dnf; then
                    sudo dnf install -y docker-compose-plugin
                else
                    sudo yum install -y docker-compose-plugin
                fi
                ;;
            "windows")
                echo "docker compose should be included with Docker Desktop"
                ;;
        esac
    else
        # Use docker compose (no dash)
        echo "Using 'docker compose' (modern syntax)"
        DOCKER_COMPOSE_CMD="docker compose"
    fi
else
    # Use docker-compose (legacy)
    DOCKER_COMPOSE_CMD="docker-compose"
fi

# Default to docker compose if not set
DOCKER_COMPOSE_CMD=${DOCKER_COMPOSE_CMD:-"docker compose"}

echo ""
echo -e "${CYAN}Step 2: Starting HYDRA development environment...${NC}"

# Navigate to nats directory and use make
cd nats

# Start the HYDRA development environment using make
echo "Starting HYDRA environment with make..."
make start

echo ""
echo -e "${GREEN}"
echo "🎉 SUCCESS! HYDRA Development Environment is Ready!"
echo "=================================================="
echo -e "${NC}"
echo -e "${BLUE}Your HYDRA development environment is now running:${NC}"
echo ""
echo "🎯 NATS Server:     nats://localhost:4222"
echo "📊 Monitoring:      http://localhost:8222"
echo "🩺 Health Check:    http://localhost:8222/healthz"
echo ""
echo -e "${BLUE}Authentication:${NC}"
echo "👤 User:            app-limited"
echo "🔑 Password:        dev-password-change-in-production"
echo ""
echo -e "${BLUE}Next steps:${NC}"
echo ""
echo -e "${YELLOW}# Test your connection (if you have curl):${NC}"
echo "curl -f http://localhost:8222/healthz"
echo ""
echo -e "${YELLOW}# Install NATS CLI for testing (optional):${NC}"
if command_exists go; then
    echo "go install github.com/nats-io/natscli/nats@latest"
    echo "nats --server localhost:4222 --user app-limited --password dev-password-change-in-production server info"
else
    echo "# First install Go from https://golang.org/doc/install"
    echo "# Then: go install github.com/nats-io/natscli/nats@latest"
fi
echo ""
echo -e "${YELLOW}# Create a simple test app:${NC}"
echo "cat > test-app.go << 'EOF'"
echo "package main"
echo ""
echo "import ("
echo "    \"fmt\""
echo "    \"log\""
echo "    \"github.com/nats-io/nats.go\""
echo ")"
echo ""
echo "func main() {"
echo "    nc, err := nats.Connect(\"nats://localhost:4222\","
echo "        nats.UserInfo(\"app-limited\", \"dev-password-change-in-production\"))"
echo "    if err != nil {"
echo "        log.Fatal(err)"
echo "    }"
echo "    defer nc.Close()"
echo ""
echo "    fmt.Println(\"✅ Connected to HYDRA development NATS!\")"
echo "    fmt.Println(\"🎯 This exact code works on HYDRA units!\")"
echo "}"
echo "EOF"
echo ""
echo "go mod init test && go get github.com/nats-io/nats.go && go run test-app.go"
echo ""
echo -e "${BLUE}Management commands (using make):${NC}"
echo "make help           # Show all available commands"
echo "make status         # Check if NATS is running"
echo "make test           # Test connectivity"
echo "make logs           # View NATS logs"
echo "make stop           # Stop the environment"
echo "make clean          # Stop and clean up everything"
echo ""
echo -e "${GREEN}🎯 Your applications can now connect to localhost:4222${NC}"
echo -e "${GREEN}   This works exactly the same on HYDRA production units!${NC}"
echo ""

# Offer to run a quick test
echo -e "${YELLOW}Would you like to run a quick connectivity test? (y/n)${NC}"
read -r response
if [[ "$response" =~ ^[Yy]$ ]]; then
    echo ""
    echo -e "${CYAN}Running connectivity test...${NC}"
    
    # Use make for testing
    make test
    
    echo ""
    echo -e "${GREEN}✅ Connectivity test completed!${NC}"
fi

echo ""
echo -e "${GREEN}🚀 Happy coding with HYDRA!${NC}"

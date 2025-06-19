# HYDRA Development Environment

Production-parity development tools for building applications that run on HYDRA units. Your code connects to `localhost:4222` in both development and production - **zero configuration changes needed**.

## Quick Start

```bash
# One command works on Windows, macOS, and Linux
git clone https://github.com/hydrahardware/hydra-public.git
cd hydra-public/dev-environment
./quick-start.sh
```

**That's it!** 🎉 You now have localhost:4222 NATS running exactly like HYDRA units.

## What This Provides

- ✅ **localhost:4222** NATS server (identical to HYDRA units)
- ✅ **Cross-platform setup** (Windows/macOS/Linux)
- ✅ **Auto-installs prerequisites** (Docker, make, etc.)
- ✅ **Professional make interface** for daily management
- ✅ **Production parity** - same code works on HYDRA units
- ✅ **Zero configuration changes** when deploying

## How It Works

### **Setup (Shell Script)** - Universal Compatibility
The `quick-start.sh` script:
1. **Detects your OS** (Windows/macOS/Linux)
2. **Auto-installs Docker** (platform-specific method)
3. **Auto-installs make** (required for management)
4. **Starts HYDRA environment** using `make start`

### **Daily Management (Make Commands)** - Professional Workflow
After setup, use professional make commands:

```bash
cd nats
make help           # Show all available commands
make start          # Start HYDRA environment
make stop           # Stop environment
make status         # Check if running
make test           # Test connectivity
make logs           # View logs
make restart        # Restart NATS
make clean          # Clean up everything
```

## Platform Support

### **Windows** 🪟
- **Git Bash** (recommended): Includes make, full compatibility
- **WSL** (Linux): Full Linux experience with auto-install
- **PowerShell**: Auto-installs make via Chocolatey

### **macOS** 🍎
- **Terminal/iTerm2**: Auto-installs Homebrew, Docker Desktop, and make
- **Full compatibility** with all macOS versions

### **Linux** 🐧
- **Ubuntu/Debian**: Auto-installs via `apt`
- **CentOS/Fedora**: Auto-installs via `dnf`/`yum`
- **Any distribution**: Docker and make via package manager

## Directory Structure

```
dev-environment/
├── quick-start.sh         # Cross-platform setup script
├── nats/                  # HYDRA NATS environment
│   ├── Makefile          # Professional management commands
│   ├── docker-compose.yml # NATS server configuration
│   ├── nats/             # NATS configuration files
│   │   ├── nats-server.conf
│   │   └── credentials.json
│   └── README.md         # Detailed NATS documentation
└── README.md             # This file
```

## Connection Details

### **NATS Server**
- **URL**: `nats://localhost:4222`
- **Monitoring**: http://localhost:8222
- **Health Check**: http://localhost:8222/healthz

### **Authentication**
- **User**: `app-limited`
- **Password**: `dev-password-change-in-production`
- **Permissions**: Access to `app.*`, `venue.dev.*`, and `telemetry.*` subjects

## Code Examples

### **Go**
```go
package main

import (
    "fmt"
    "log"
    "github.com/nats-io/nats.go"
)

func main() {
    // This exact code works on HYDRA units!
    nc, err := nats.Connect("nats://localhost:4222",
        nats.UserInfo("app-limited", "dev-password-change-in-production"))
    if err != nil {
        log.Fatal(err)
    }
    defer nc.Close()

    fmt.Println("✅ Connected to HYDRA development NATS!")
    fmt.Println("🎯 This exact code works on HYDRA units!")
}
```

### **Python**
```python
import asyncio
from nats.aio.client import Client as NATS

async def main():
    nc = NATS()
    await nc.connect(
        servers=["nats://localhost:4222"],
        user="app-limited",
        password="dev-password-change-in-production"
    )
    
    print("✅ Connected to HYDRA development NATS!")
    print("🎯 This exact code works on HYDRA units!")
    
    await nc.close()

asyncio.run(main())
```

### **JavaScript/Node.js**
```javascript
const { connect } = require('nats');

async function main() {
    const nc = await connect({
        servers: 'nats://localhost:4222',
        user: 'app-limited',
        pass: 'dev-password-change-in-production'
    });
    
    console.log('✅ Connected to HYDRA development NATS!');
    console.log('🎯 This exact code works on HYDRA units!');
    
    await nc.close();
}

main();
```

## Subject Namespaces

Use these subject patterns for your applications:

```
app.yourapp.*              # Your application namespace
app.nimsforest.*           # NimsForest namespace (example)
telemetry.yourapp.*        # Your app's telemetry
venue.dev.*                # Development venue subjects
```

## Daily Development Workflow

### **1. Start Development**
```bash
cd hydra-public/dev-environment/nats
make start
```

### **2. Develop Your Application**
```go
// Your app connects to localhost:4222
nc, err := nats.Connect("nats://localhost:4222", ...)
```

### **3. Test and Debug**
```bash
make test           # Test connectivity
make logs           # View NATS logs if needed
make status         # Check if everything is running
```

### **4. Stop When Done**
```bash
make stop           # Clean shutdown
```

### **5. Deploy to HYDRA (Zero Changes!)**
```bash
# Copy your application to HYDRA unit
scp myapp hydra-unit:/opt/myapp/

# Run on HYDRA unit - same code, same config!
ssh hydra-unit "./myapp"
# Connects to localhost:4222 on HYDRA unit too!
```

## Testing Your Setup

### **Basic Connectivity Test**
```bash
cd nats
make test
```

### **Manual Testing**
```bash
# Test HTTP monitoring
curl http://localhost:8222/healthz

# Install NATS CLI for advanced testing
make install-cli

# Test NATS messaging
nats --server localhost:4222 --user app-limited --password dev-password-change-in-production server info
```

### **Application Testing**
Create a simple test application:

```bash
cat > test-app.go << 'EOF'
package main

import (
    "fmt"
    "log"
    "github.com/nats-io/nats.go"
)

func main() {
    nc, err := nats.Connect("nats://localhost:4222",
        nats.UserInfo("app-limited", "dev-password-change-in-production"))
    if err != nil {
        log.Fatal(err)
    }
    defer nc.Close()

    fmt.Println("✅ Connected to HYDRA development NATS!")
}
EOF

go mod init test && go get github.com/nats-io/nats.go && go run test-app.go
```

## Integration Examples

### **NimsForest Integration**
```yaml
# nimsforest-config.yml - Same in dev and production!
wind:
  nats_url: "nats://localhost:4222"
  namespace: "app.nimsforest.wind"
  auth:
    user: "app-limited"
    password: "dev-password-change-in-production"
```

### **Custom Application Integration**
```go
// Your application configuration
type Config struct {
    NATSURL      string `json:"nats_url"`      // "nats://localhost:4222"
    NATSUser     string `json:"nats_user"`     // "app-limited"  
    NATSPassword string `json:"nats_password"` // Read from config
    Namespace    string `json:"namespace"`     // "app.yourapp"
}
```

## Troubleshooting

### **Common Issues**

#### Docker Not Running
```bash
# Check Docker status
docker info

# Start Docker
# Windows: Start Docker Desktop
# Linux: sudo systemctl start docker
# macOS: Start Docker Desktop
```

#### NATS Not Starting
```bash
# Check logs
make logs

# Restart NATS
make restart

# Check if ports are in use
netstat -an | grep -E ":4222|:8222"
```

#### Permission Denied (Linux)
```bash
# Add user to docker group
sudo usermod -aG docker $USER

# Log out and back in, then try again
```

### **Getting Help**
- **View all commands**: `make help`
- **Check status**: `make status`
- **Test connectivity**: `make test`
- **View logs**: `make logs`
- **HYDRA Documentation**: [docs.hydrahardware.io](https://docs.hydrahardware.io)

## Production Deployment

### **What Changes in Production**
1. **Credentials**: Read from HYDRA config files instead of hardcoded
2. **Security**: Production uses certificate-based authentication
3. **Everything else**: Identical!

### **Production Credential Pattern**
```go
// Environment detection
func getCredentials() (string, string) {
    if isDevelopment() {
        return "app-limited", "dev-password-change-in-production"
    }
    
    // Production: read from HYDRA config
    creds, _ := os.ReadFile("C:/Hydra/Horde/config/app-credentials.json")
    var config HydraCredentials
    json.Unmarshal(creds, &config)
    return "app-limited", config.AppLimitedPassword
}

func connectToNATS() (*nats.Conn, error) {
    user, password := getCredentials()
    return nats.Connect(
        "nats://localhost:4222",  // Same URL everywhere!
        nats.UserInfo(user, password),
    )
}
```

## Advanced Features

### **Monitoring**
```bash
# Start monitoring dashboard
make monitor

# View monitoring
open http://localhost:7777  # Advanced monitoring
open http://localhost:8222  # NATS monitoring
```

### **Multiple User Types**
The development environment supports different authentication levels:
- **app-limited**: Normal application development
- **horde-system**: Testing HYDRA horde features
- **developer**: Full access for debugging

### **Subject Permissions**
Your applications are automatically restricted to appropriate subject namespaces:
- ✅ Can access: `app.*`, `venue.dev.*`, `telemetry.*`
- ❌ Cannot access: `horde.*` (HYDRA internal), other apps' subjects

## Why This Approach Works

### **Development Benefits**
- 🚀 **One-command setup** works everywhere
- 🛠️ **Professional make interface** for daily work
- 🔄 **Hot reload friendly** - restart NATS quickly during development
- 📊 **Built-in monitoring** for debugging

### **Production Benefits**
- 🎯 **Zero configuration changes** needed
- 🔐 **Same authentication patterns** (just different credentials)
- 📡 **Same subject namespaces** work everywhere
- 🏗️ **Same localhost:4222 URL** in all environments

### **Platform Benefits**
- 🌍 **Cross-platform support** (Windows/macOS/Linux)
- 🐳 **Docker consistency** across all platforms
- 🔧 **Auto-installs prerequisites** where possible
- 📚 **Comprehensive documentation** and examples

This development environment gives you **production parity** - your development setup exactly matches what your application will experience on any HYDRA unit, making deployment completely seamless!

## Next Steps

1. **Run the quick start**: `./quick-start.sh`
2. **Explore the commands**: `cd nats && make help`
3. **Test your connection**: `make test`
4. **Start building**: Connect your app to `localhost:4222`
5. **Deploy to HYDRA**: Same code, zero changes!

Happy coding with HYDRA! 🚀

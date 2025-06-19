# HYDRA Development NATS Environment

Production-parity NATS server for developing applications that will run on HYDRA units. Your code connects to `localhost:4222` in both development and production - **zero configuration changes needed**.

## Quick Start

```bash
# Start HYDRA development environment
make start

# Your application connects to localhost:4222
# This works identically on HYDRA units!
```

## What This Provides

- ✅ **localhost:4222** NATS server (identical to HYDRA units)
- ✅ **Production-matching authentication** and subject namespaces
- ✅ **Development monitoring** at http://localhost:8222
- ✅ **Optional monitoring dashboard** at http://localhost:7777
- ✅ **Zero config changes** when deploying to HYDRA

## Available Commands

```bash
make help          # Show all available commands
make start         # Start HYDRA development environment
make stop          # Stop environment
make restart       # Restart NATS server
make status        # Check if running
make test          # Test connectivity and functionality
make health        # Quick health check
make logs          # View NATS server logs
make monitor       # Start monitoring dashboard
make clean         # Stop and remove everything
make info          # Show connection details
```

## Connection Details

### **NATS Server**
- **URL**: `nats://localhost:4222`
- **Monitoring**: http://localhost:8222
- **Health Check**: http://localhost:8222/healthz

### **Authentication**
Three user levels available:

#### **app-limited** (Recommended for most applications)
```json
{
  "user": "app-limited",
  "password": "dev-password-change-in-production",
  "permissions": {
    "subscribe": ["app.>", "venue.dev.>", "telemetry.>"],
    "publish": ["app.>", "venue.dev.>", "telemetry.>"]
  }
}
```

#### **horde-system** (For testing HYDRA horde features)
```json
{
  "user": "horde-system", 
  "password": "dev-horde-password",
  "permissions": {
    "subscribe": ["horde.>", "weerwolf.>", "experiences.>"],
    "publish": ["horde.>", "weerwolf.>", "experiences.>"]
  }
}
```

#### **developer** (Full access for debugging)
```json
{
  "user": "developer",
  "password": "dev-full-access",
  "permissions": {
    "subscribe": [">"],
    "publish": [">"]
  }
}
```

## Subject Namespaces

### **Application Subjects** (Use these for your app)
```
app.yourapp.*              # Your application namespace
app.nimsforest.*           # NimsForest namespace
telemetry.yourapp.*        # Your app's telemetry
```

### **Development Venue Subjects**
```
venue.dev.*                # Development venue
venue.dev.status           # Venue status
venue.dev.events.*         # Venue events
```

### **HYDRA Horde Subjects** (For testing horde features)
```
horde.discovery.*          # Peer discovery
horde.status.*             # Horde status
weerwolf.light.*           # Content generation
experiences.*              # Experience lifecycle
```

## Code Examples

### **Go**
```go
package main

import (
    "log"
    "github.com/nats-io/nats.go"
)

func main() {
    // Connect to HYDRA development NATS
    nc, err := nats.Connect(
        "nats://localhost:4222",
        nats.UserInfo("app-limited", "dev-password-change-in-production"),
        nats.Name("my-app-dev"),
    )
    if err != nil {
        log.Fatal("Failed to connect:", err)
    }
    defer nc.Close()

    // Subscribe to your app's subjects
    nc.Subscribe("app.myapp.*", func(msg *nats.Msg) {
        log.Printf("Received: %s", string(msg.Data))
    })

    // Publish a message
    nc.Publish("app.myapp.hello", []byte("Hello from development!"))
    
    // This exact code works on HYDRA units!
}
```

### **Python**
```python
import asyncio
import json
from nats.aio.client import Client as NATS

async def main():
    nc = NATS()
    
    # Connect to HYDRA development NATS
    await nc.connect(
        servers=["nats://localhost:4222"],
        user="app-limited",
        password="dev-password-change-in-production"
    )
    
    # Subscribe to your app's subjects
    async def message_handler(msg):
        print(f"Received: {msg.data.decode()}")
    
    await nc.subscribe("app.myapp.*", cb=message_handler)
    
    # Publish a message
    await nc.publish("app.myapp.hello", b"Hello from Python!")
    
    # This exact code works on HYDRA units!
    
    await asyncio.sleep(1)
    await nc.close()

if __name__ == "__main__":
    asyncio.run(main())
```

### **JavaScript/Node.js**
```javascript
const { connect } = require('nats');

async function main() {
    // Connect to HYDRA development NATS
    const nc = await connect({
        servers: 'nats://localhost:4222',
        user: 'app-limited',
        pass: 'dev-password-change-in-production'
    });
    
    // Subscribe to your app's subjects
    const subscription = nc.subscribe('app.myapp.*');
    (async () => {
        for await (const msg of subscription) {
            console.log(`Received: ${msg.string()}`);
        }
    })();
    
    // Publish a message
    nc.publish('app.myapp.hello', 'Hello from JavaScript!');
    
    // This exact code works on HYDRA units!
}

main().catch(console.error);
```

## NimsForest Integration Example

### **Configuration**
```yaml
# nimsforest-config.yml - SAME in dev and production!
wind:
  nats_url: "nats://localhost:4222"
  namespace: "app.nimsforest.wind"
  auth:
    user: "app-limited"
    password: "dev-password-change-in-production"
```

### **Usage**
```bash
# Start HYDRA development environment
make start

# Run NimsForest with the above config
./nimsforest --config nimsforest-config.yml

# NimsForest connects to localhost:4222 and works exactly like production!
```

## Development Workflow

### **1. Initial Setup**
```bash
# Clone HYDRA public resources
git clone https://github.com/hydrahardware/hydra-public.git
cd hydra-public/dev-environment/nats

# Start development environment
make start
```

### **2. Daily Development**
```bash
# Start environment
make start

# Develop your application (connects to localhost:4222)
go run main.go
# or
python app.py
# or  
npm start

# Test connectivity
make test

# View logs if needed
make logs

# Stop when done
make stop
```

### **3. Testing Cross-Application Communication**
```bash
# Terminal 1: Start your app
go run main.go

# Terminal 2: Subscribe to messages with NATS CLI
nats --server localhost:4222 --user app-limited --password dev-password-change-in-production \
     sub "app.myapp.*"

# Terminal 3: Publish test messages
nats --server localhost:4222 --user app-limited --password dev-password-change-in-production \
     pub app.myapp.test "test message"
```

### **4. Deploy to HYDRA (Zero Changes!)**
```bash
# Copy your exact application to HYDRA unit
scp myapp hydra-unit:/opt/myapp/

# Run on HYDRA unit - same code, same config!
ssh hydra-unit "/opt/myapp/myapp"
# Connects to localhost:4222 on the HYDRA unit
```

## Monitoring and Debugging

### **NATS Monitoring**
- **Server Stats**: http://localhost:8222/varz
- **Connection Info**: http://localhost:8222/connz
- **Subscription Info**: http://localhost:8222/subsz
- **Health Check**: http://localhost:8222/healthz

### **Monitoring Dashboard**
```bash
# Start advanced monitoring
make monitor

# Open dashboard
open http://localhost:7777
```

### **Common Debugging Commands**
```bash
# Check status
make status

# Test connectivity
make health

# View detailed logs
make logs

# Debug connection issues
make debug

# Test with NATS CLI
nats --server localhost:4222 --user app-limited --password dev-password-change-in-production \
     server info
```

## Production Deployment

### **What Changes in Production**
1. **Credentials**: Read from HYDRA config files instead of hardcoded dev passwords
2. **Security**: Production uses certificate-based authentication and stronger passwords
3. **Everything else**: Identical!

### **Reading Production Credentials**
```go
// Production credential reading
func getProductionCredentials() (string, string) {
    // Read from HYDRA configuration
    creds, _ := os.ReadFile("C:/Hydra/Horde/config/app-credentials.json")
    var config HydraCredentials
    json.Unmarshal(creds, &config)
    return "app-limited", config.AppLimitedPassword
}
```

### **Environment Detection**
```go
func connectToNATS() (*nats.Conn, error) {
    var user, password string
    
    if isDevelopment() {
        user = "app-limited"
        password = "dev-password-change-in-production"
    } else {
        user, password = getProductionCredentials()
    }
    
    return nats.Connect(
        "nats://localhost:4222",  // Always localhost:4222!
        nats.UserInfo(user, password),
    )
}
```

## Files in This Directory

- **Makefile**: Development workflow commands
- **docker-compose.yml**: Docker orchestration for NATS
- **nats/nats-server.conf**: NATS server configuration (matches HYDRA)
- **nats/credentials.json**: Development credentials and examples
- **README.md**: This documentation

## Advanced Features

### **JetStream (Message Persistence)**
JetStream is enabled for advanced development scenarios:
```bash
# Create a stream (persistent messages)
nats --server localhost:4222 --user developer --password dev-full-access \
     stream add EVENTS --subjects="app.myapp.events.*"

# Publish persistent message  
nats --server localhost:4222 --user developer --password dev-full-access \
     pub app.myapp.events.user_login "{"user":"dev","timestamp":"$(date)"}"
```

### **Simulating Multiple HYDRA Units**
```bash
# Run multiple instances with different venue IDs
docker-compose -p venue1 up -d
docker-compose -p venue2 -f docker-compose.yml -f docker-compose.multi.yml up -d

# Test cross-venue communication
```

## Getting Help

- **HYDRA Documentation**: [docs.hydrahardware.io](https://docs.hydrahardware.io)
- **NATS Documentation**: [docs.nats.io](https://docs.nats.io)
- **Issues**: [github.com/hydrahardware/hydra-public/issues](https://github.com/hydrahardware/hydra-public/issues)
- **Examples**: [github.com/hydrahardware/hydra-public/tree/main/examples](https://github.com/hydrahardware/hydra-public/tree/main/examples)

## NATS CLI Installation

```bash
# Install NATS CLI for testing
make install-cli

# Or manually:
go install github.com/nats-io/natscli/nats@latest
```

This development environment gives you **production parity** - your development setup exactly matches what your application will experience on any HYDRA unit, making deployment completely seamless!

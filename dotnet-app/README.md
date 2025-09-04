# DatadogChecker - .NET Core Application for Datadog Integration Testing

A comprehensive .NET 9.0 web API application designed to test Datadog connectivity, generate structured logs, and demonstrate proper Datadog Agent integration in Kubernetes environments.

## 🎯 What This Project Does

**DatadogChecker** is a demonstration application that:

- **Tests Datadog Connectivity**: Provides HTTP endpoints to verify network connectivity to Datadog services
- **Generates Structured Logs**: Uses Serilog with JSON formatting optimized for Datadog log collection
- **Kubernetes Ready**: Complete deployment manifests with working Datadog Agent configuration
- **APM Integration**: Configured for Datadog Application Performance Monitoring
- **Health Monitoring**: Built-in health checks and diagnostic endpoints

### Key Features

- ✅ HTTP API with multiple test endpoints
- ✅ Structured JSON logging with Datadog enrichment
- ✅ Docker containerization
- ✅ Kubernetes deployment with proper networking
- ✅ Working Datadog Agent configuration (solves common kubelet TLS issues)
- ✅ Health checks and monitoring endpoints
- ✅ Development and production configurations

## 📋 Prerequisites

### Development Environment

1. **[.NET 9.0 SDK](https://dotnet.microsoft.com/download/dotnet/9.0)** - Required for building and running locally
2. **[Docker Desktop](https://www.docker.com/products/docker-desktop/)** - For containerization and local Kubernetes
3. **Kubernetes** - Either:
   - Docker Desktop with Kubernetes enabled (recommended for local development)
   - [minikube](https://minikube.sigs.k8s.io/docs/start/)
4. **[kubectl](https://kubernetes.io/docs/tasks/tools/)** - Kubernetes command-line tool

### Datadog Account & API Keys

You'll need a Datadog account with the following credentials:

1. **Datadog API Key**:
   - Go to [Datadog → Organization Settings → API Keys](https://app.datadoghq.com/organization-settings/api-keys)
   - Create a new API key or use an existing one
   - Copy the key value

2. **Datadog Application Key** (optional, for advanced features):
   - Go to [Datadog → Organization Settings → Application Keys](https://app.datadoghq.com/organization-settings/application-keys)
   - Create a new application key
   - Copy the key value

3. **Datadog Site**: Confirm your site URL (e.g., `datadoghq.com`, `datadoghq.eu`, `us3.datadoghq.com`)

## 🚀 Local Installation and Setup

### Method 1: Using the Provided Script (Recommended)

The easiest way to run the application locally:

```bash
# Make the script executable
chmod +x start-app.sh

# Run on default port 8080
./start-app.sh

# Or specify a custom port
./start-app.sh 8081
```

**What the script does:**
- ✅ Checks for .NET 9.0 SDK
- ✅ Handles port conflicts automatically
- ✅ Restores NuGet packages
- ✅ Cleans and builds the project
- ✅ Creates necessary directories
- ✅ Starts the application with proper configuration

### Method 2: Manual Setup

If you prefer to set up manually:

```bash
# Clone the repository (if not already done)
git clone git@github.com:crofty13/Datadog.git
cd Datadog/dotnet-app

# Restore dependencies
dotnet restore

# Build the project
dotnet build

# Create logs directory
mkdir -p logs

# Run the application
dotnet run --urls="http://localhost:8080"
```

### Verify Local Installation

Once running, test these endpoints:

```bash
# Health check
curl http://localhost:8080/health

# Test Datadog connectivity
curl -X POST http://localhost:8080/api/status/check-datadog

# Get application traces info
curl http://localhost:8080/api/status/traces

# Debug information
curl http://localhost:8080/api/status/debug
```

## 🐳 Kubernetes Deployment on Docker Desktop

### Step 1: Enable Kubernetes in Docker Desktop

1. Open Docker Desktop
2. Go to Settings → Kubernetes
3. Check "Enable Kubernetes"
4. Click "Apply & Restart"
5. Wait for Kubernetes to start (green status)

### Step 2: Deploy the Application

```bash
# Navigate to Kubernetes manifests
cd k8s-files

# Make deployment script executable
chmod +x k8s-deploy-local.sh

# Deploy to Kubernetes
./k8s-deploy-local.sh
```

**What the deployment script does:**
- 🔨 Builds the Docker image locally
- 📁 Creates the `apps` namespace
- 🚀 Deploys all Kubernetes manifests
- ⏳ Waits for pods to be ready
- 📋 Shows service and pod information
- 🔗 Provides access instructions

### Step 3: Access the Application

After deployment, you have several options to access the app:

```bash
# Option 1: Port forwarding (recommended)
kubectl port-forward service/datadog-checker-service 8080:8080 -n apps

# Then visit: http://localhost:8080
```

```bash
# Option 2: Get NodePort and access directly
kubectl get service datadog-checker-service -n apps
# Use the NodePort shown in the output
```

### Step 4: Deploy Datadog Agent (Essential for Log Collection)

To collect logs and metrics, deploy the Datadog Agent:

```bash
# Navigate back to project root
cd ..

# Install Datadog Operator (one-time setup)
helm repo add datadog https://helm.datadoghq.com
helm install datadog-operator datadog/datadog-operator

# Create API key secret (replace with your actual API key)
kubectl create secret generic datadog-secret \
  --from-literal api-key="YOUR_DATADOG_API_KEY" \
  --namespace default

# Deploy Datadog Agent with working configuration
kubectl apply -f "Datadog Agent/datadog-agent-working-config.yaml"
```

> **💡 Important**: The included `datadog-agent-working-config.yaml` contains a **critical fix** for Docker Desktop environments (`DD_KUBELET_TLS_VERIFY: false`) that enables proper log collection.

### Verify Kubernetes Deployment

```bash
# Check application pods
kubectl get pods -n apps

# Check application logs
kubectl logs -l app=datadog-checker -f -n apps

# Check Datadog Agent status
kubectl get pods -l app.kubernetes.io/name=datadog-agent-deployment

# Verify Datadog Agent is collecting logs
kubectl exec -it $(kubectl get pods -l app.kubernetes.io/name=datadog-agent-deployment -o jsonpath='{.items[0].metadata.name}') -c agent -- agent status | grep -A 10 "Logs Agent"
```

## 🔍 Application Endpoints

Once running (locally or in Kubernetes), the following endpoints are available:

### Core Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| `GET` | `/health` | Health check endpoint (returns JSON status) |
| `GET` | `/` | Static web page (served from `wwwroot/`) |

### API Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| `POST` | `/api/status/check-datadog` | Tests connectivity to www.datadoghq.com |
| `POST` | `/api/status/check-datacat` | Tests connectivity to www.datacat.com |
| `GET` | `/api/status/traces` | Returns APM/tracing information |
| `GET` | `/api/status/debug` | Comprehensive diagnostic information |

### Example Usage

```bash
# Health check
curl http://localhost:8080/health

# Test Datadog connectivity with detailed timing
curl -X POST http://localhost:8080/api/status/check-datadog

# Get debug information
curl http://localhost:8080/api/status/debug
```

## 📊 Datadog Integration

### Log Collection

The application generates structured JSON logs that include:

- **Service identification**: `service: datadog-checker`
- **Environment context**: `environment: Development`
- **Request tracing**: Request IDs and correlation
- **Timing information**: Response times and performance metrics
- **Error details**: Comprehensive error logging with context

### APM (Application Performance Monitoring)

- Configured for automatic .NET instrumentation
- Trace correlation between logs and APM
- Distributed tracing support

### Viewing Your Data in Datadog

After deployment with the Datadog Agent:

1. **Logs**: Go to [Datadog Logs Explorer](https://app.datadoghq.com/logs)
   - Search: `service:datadog-checker`
   - Search: `kube_namespace:apps`

2. **Infrastructure**: Go to [Infrastructure → Containers](https://app.datadoghq.com/containers)
   - View your Kubernetes pods and containers

3. **APM**: Go to [APM → Services](https://app.datadoghq.com/apm/services)
   - Look for `datadog-checker-noapm` service

## 🛠️ Troubleshooting

### Common Issues

#### 1. Port Already in Use
```bash
# The start-app.sh script handles this automatically, but if running manually:
lsof -i :8080  # Check what's using the port
# Use a different port: dotnet run --urls="http://localhost:8081"
```

#### 2. .NET SDK Not Found
```bash
# Install .NET 9.0 SDK from:
# https://dotnet.microsoft.com/download/dotnet/9.0

# Verify installation:
dotnet --version
```

#### 3. Kubernetes Pod Not Starting
```bash
# Check pod status and events
kubectl describe pod -l app=datadog-checker -n apps

# Check logs
kubectl logs -l app=datadog-checker -n apps

# Check if image was built
docker images | grep datadog-checker
```

#### 4. No Logs in Datadog
```bash
# Verify Datadog Agent is running
kubectl get pods -l app.kubernetes.io/name=datadog-agent-deployment

# Check agent logs processing (should show LogsProcessed > 0)
kubectl exec -it $(kubectl get pods -l app.kubernetes.io/name=datadog-agent-deployment -o jsonpath='{.items[0].metadata.name}') -c agent -- agent status | grep -A 10 "Logs Agent"

# Verify kubelet connectivity (common issue)
kubectl logs -l app.kubernetes.io/name=datadog-agent-deployment -c agent | grep kubelet
```

#### 5. Build Failures
```bash
# Clean build artifacts
rm -rf bin obj
dotnet clean
dotnet restore
dotnet build
```

### Debug Information

Generate comprehensive debug information:

```bash
# Application debug endpoint
curl http://localhost:8080/api/status/debug

# Kubernetes diagnostic info
kubectl get all -n apps
kubectl describe deployment datadog-checker -n apps
```

## 📁 Project Structure

```
dotnet-app/
├── Controllers/
│   └── StatusController.cs        # API endpoints
├── Datadog Agent/
│   ├── datadog-agent-working-config.yaml  # Working Datadog Agent config
│   └── DATADOG_DEPLOYMENT_GUIDE.md        # Detailed Datadog setup guide
├── k8s-files/
│   ├── deployment.yaml            # Kubernetes deployment
│   ├── service.yaml               # Kubernetes service
│   ├── namespace.yaml             # Apps namespace
│   ├── configmap.yaml             # Configuration
│   ├── networkpolicy.yaml         # Network policies
│   └── k8s-deploy-local.sh        # Deployment script
├── wwwroot/
│   └── index.html                 # Static web content
├── Program.cs                     # Application entry point
├── DatadogChecker.csproj          # Project configuration
├── Dockerfile                     # Container configuration
├── start-app.sh                   # Local development script
└── README.md                      # This file
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/your-feature`
3. Make your changes
4. Test locally and in Kubernetes
5. Commit: `git commit -m "Add your feature"`
6. Push: `git push origin feature/your-feature`
7. Create a Pull Request

## 📝 License

This project is part of the `crofty13/Datadog` repository and is intended for educational and demonstration purposes.

## 🔗 Useful Links

- [Datadog Documentation](https://docs.datadoghq.com/)
- [.NET 9.0 Documentation](https://docs.microsoft.com/en-us/dotnet/)
- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [Docker Desktop Documentation](https://docs.docker.com/desktop/)
- [Serilog Documentation](https://serilog.net/)

---

## 🎉 Quick Start Summary

```bash
# 1. Clone and navigate
git clone git@github.com:crofty13/Datadog.git
cd Datadog/dotnet-app

# 2. Run locally
chmod +x start-app.sh
./start-app.sh

# 3. Deploy to Kubernetes
cd k8s-files
chmod +x k8s-deploy-local.sh
./k8s-deploy-local.sh

# 4. Setup Datadog Agent (with your API key)
kubectl create secret generic datadog-secret --from-literal api-key="YOUR_API_KEY"
kubectl apply -f "../Datadog Agent/datadog-agent-working-config.yaml"

# 5. Access and test
kubectl port-forward service/datadog-checker-service 8080:8080 -n apps
curl http://localhost:8080/health
```

**That's it! Your DatadogChecker application should now be running and sending logs to Datadog! 🚀**

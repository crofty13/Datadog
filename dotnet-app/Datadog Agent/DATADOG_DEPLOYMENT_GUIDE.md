# Datadog Agent Deployment Guide

## Overview
This guide provides the working configuration for deploying Datadog Agent via the Datadog Operator with full log collection support for Docker Desktop and local Kubernetes environments.

## Prerequisites

1. **Install Datadog Operator**:
   ```bash
   helm repo add datadog https://helm.datadoghq.com
   helm install datadog-operator datadog/datadog-operator
   ```

2. **Get Your Datadog API Key**:
   - Go to Datadog → Organization Settings → API Keys
   - Copy your API key

## Deployment Steps

### 1. Create API Key Secret

Replace `YOUR_DATADOG_API_KEY` with your actual API key:

```bash
# Create the secret with your API key
kubectl create secret generic datadog-secret \
  --from-literal api-key="YOUR_DATADOG_API_KEY" \
  --namespace default
```

### 2. Deploy Datadog Agent

```bash
kubectl apply -f datadog-agent-working-config.yaml
```

### 3. Verify Deployment

```bash
# Check DatadogAgent status
kubectl get DatadogAgent datadog

# Check agent pods
kubectl get pods -l app.kubernetes.io/name=datadog-agent-deployment

# Check agent logs
kubectl logs -l app.kubernetes.io/name=datadog-agent-deployment -c agent --tail=10
```

### 4. Verify Log Collection

```bash
# Check if logs are being processed
kubectl exec -it $(kubectl get pods -l app.kubernetes.io/name=datadog-agent-deployment -o jsonpath='{.items[0].metadata.name}') -c agent -- agent status | grep -A 10 "Logs Agent"
```

You should see:
- `LogsProcessed: > 0` (not zero)
- `LogsSent: > 0` (not zero) 
- `RetryCount: 0` (no errors)

## Key Configuration Explained

### Critical Fix for Local Kubernetes
The most important part of this configuration is:

```yaml
override:
  nodeAgent:
    env:
    - name: DD_KUBELET_TLS_VERIFY
      value: "false"
```

**Why this is needed:**
- Docker Desktop, minikube, kind, and other local Kubernetes environments use self-signed certificates
- Without this setting, the Datadog agent cannot connect to kubelet
- This results in `LogsProcessed: 0` and no container logs being collected
- This fix allows the agent to discover and tail container log files

### Log Collection Features
```yaml
logCollection:
  enabled: true              # Enables log forwarding to Datadog
  containerCollectAll: true  # Collects from ALL containers automatically
```

### APM Auto-Instrumentation
```yaml
apm:
  instrumentation:
    enabled: true  # Automatically instruments applications
    targets:       # Specifies tracer versions for different languages
```

## Troubleshooting

### No Logs Appearing in Datadog

1. **Check agent status**:
   ```bash
   kubectl exec -it <datadog-agent-pod> -c agent -- agent status
   ```

2. **Look for LogsProcessed > 0**:
   - If `LogsProcessed: 0`, the kubelet TLS issue hasn't been resolved
   - Ensure `DD_KUBELET_TLS_VERIFY: "false"` is set

3. **Check for kubelet errors**:
   ```bash
   kubectl logs <datadog-agent-pod> -c agent | grep kubelet
   ```

### Common Issues

- **"impossible to reach Kubelet"**: Add `DD_KUBELET_TLS_VERIFY: "false"`
- **API key errors**: Verify your secret contains the correct API key
- **No traces**: Ensure your application has Datadog tracing configured

## Testing Log Collection

Generate test logs from your application:

```bash
# Health check endpoint
curl http://localhost:8080/health

# Application-specific endpoints  
curl -X POST http://localhost:8080/api/status/check-datadog
curl http://localhost:8080/api/status/debug
```

Then search in Datadog Logs Explorer:
- `service:datadog-checker`
- `kube_namespace:apps`
- `source:kubernetes`

## Production Considerations

**For production environments:**
- Change `DD_KUBELET_TLS_VERIFY` to `"true"` if your kubelet has proper certificates
- Consider using dedicated namespaces for monitoring components
- Review and adjust log retention and indexing settings in Datadog
- Set appropriate resource limits for the agent pods

## Files in This Setup

1. `datadog-agent-working-config.yaml` - Complete DatadogAgent configuration
2. `DATADOG_DEPLOYMENT_GUIDE.md` - This deployment guide

Both configurations have been tested and verified to work with:
- Docker Desktop Kubernetes
- Full log collection from all containers
- APM trace collection  
- Proper kubelet connectivity

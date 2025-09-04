#!/bin/bash

echo "🚀 Deploying Datadog Checker to 'apps' namespace in local Kubernetes..."

# Check if Kubernetes is available
if ! kubectl cluster-info &> /dev/null; then
    echo "❌ Kubernetes cluster not available. Please ensure:"
    echo "   - Docker Desktop has Kubernetes enabled, OR"
    echo "   - minikube is running"
    exit 1
fi

# Build the image locally
echo "🔨 Building Docker image..."
docker build -t datadog-checker-noapm:latest -f ../Dockerfile

# Check if we're using Docker Desktop or minikube
if kubectl config current-context | grep -q "docker-desktop"; then
    echo "✅ Detected Docker Desktop Kubernetes - image already available"
elif kubectl config current-context | grep -q "minikube"; then
    echo "📥 Loading image into minikube..."
    minikube image load datadog-checker:latest
else
    echo "⚠️  Unknown Kubernetes context, proceeding anyway..."
fi

# Create logs directory on host
mkdir -p /tmp/datadog-checker-logs

# Create namespace first
echo "📁 Creating 'apps' namespace..."
kubectl apply -f namespace.yaml

# Apply Kubernetes manifests
echo "🚀 Applying Kubernetes manifests to 'apps' namespace..."
kubectl apply -f configmap.yaml
kubectl apply -f deployment.yaml
kubectl apply -f service.yaml
kubectl apply -f networkpolicy.yaml

# Wait for deployment
echo "⏳ Waiting for deployment to be ready..."
kubectl wait --for=condition=available --timeout=120s deployment/datadog-checker -n apps

# Get service info
echo "📋 Service Information:"
kubectl get services -l app=datadog-checker -n apps

# Get pod info
echo "📋 Pod Information:"
kubectl get pods -l app=datadog-checker -n apps

# Get access instructions
echo ""
echo "🎉 Deployment complete in 'apps' namespace!"
echo ""
echo "📍 To access the application:"

# Check for LoadBalancer
LB_IP=$(kubectl get service datadog-checker-lb -n apps -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>/dev/null)
if [[ -n "$LB_IP" && "$LB_IP" != "null" ]]; then
    echo "   LoadBalancer: http://$LB_IP:8080"
fi

# NodePort access
NODE_PORT=$(kubectl get service datadog-checker-service -n apps -o jsonpath='{.spec.ports[0].nodePort}')
if [[ -n "$NODE_PORT" ]]; then
    echo "   NodePort: http://localhost:$NODE_PORT"
fi

echo "   Port Forward: kubectl port-forward service/datadog-checker-service 8080:8080 -n apps"
echo "   Then visit: http://localhost:8080"

echo ""
echo "🔍 Useful commands:"
echo "   View logs: kubectl logs -l app=datadog-checker -f -n apps"
echo "   Get pods: kubectl get pods -l app=datadog-checker -n apps"
echo "   Get services: kubectl get services -n apps"
echo "   Get all resources: kubectl get all -n apps"
echo "   Delete: kubectl delete -f . (will delete from apps namespace)"

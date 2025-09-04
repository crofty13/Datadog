#!/bin/bash

echo "🧹 Cleaning up Datadog Checker deployment from 'apps' namespace..."

kubectl delete -f service.yaml
kubectl delete -f deployment.yaml
kubectl delete -f configmap.yaml
kubectl delete -f networkpolicy.yaml

# Ask if user wants to delete the namespace
read -p "🗑️  Delete the 'apps' namespace? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    kubectl delete namespace apps
    echo "✅ Namespace 'apps' deleted"
else
    echo "ℹ️  Namespace 'apps' preserved"
fi

echo "✅ Cleanup complete!"

# Optionally remove logs
read -p "🗑️  Remove log files? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    rm -rf /tmp/datadog-checker-logs
    echo "✅ Log files removed"
fi

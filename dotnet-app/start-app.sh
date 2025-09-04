#!/bin/bash

# ============================================================================
# DatadogChecker - Unified Local Startup Script
# ============================================================================
# This script combines the functionality of startup.sh and run-local.sh
# Requirements: .NET 9.0 SDK
# Usage: ./start-app.sh [PORT]
# Example: ./start-app.sh 8081
# ============================================================================

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default configuration
DEFAULT_PORT=8080
FALLBACK_PORT=8081
PORT=${1:-$DEFAULT_PORT}

echo -e "${BLUE}=====================================${NC}"
echo -e "${BLUE}  DatadogChecker Local Startup${NC}"
echo -e "${BLUE}=====================================${NC}"
echo

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_step() {
    echo -e "${BLUE}[STEP]${NC} $1"
}

# Check if port is in use
check_port() {
    local port=$1
    if lsof -i :$port > /dev/null 2>&1; then
        return 1  # Port is in use
    else
        return 0  # Port is free
    fi
}

# Check prerequisites
print_step "Checking prerequisites..."

# Check for .NET SDK
if ! command -v dotnet &> /dev/null; then
    print_error ".NET SDK not found. Please install .NET 9.0 SDK"
    print_status "Download from: https://dotnet.microsoft.com/download/dotnet/9.0"
    exit 1
fi

# Check .NET version
DOTNET_VERSION=$(dotnet --version)
print_status "Found .NET SDK version: $DOTNET_VERSION"

if [[ ! "$DOTNET_VERSION" =~ ^9\. ]]; then
    print_warning "This application requires .NET 9.0. Current version: $DOTNET_VERSION"
    print_status "Continuing anyway, but you may encounter issues..."
fi

# Check and handle port conflicts
print_step "Checking port availability..."

if ! check_port $PORT; then
    print_warning "Port $PORT is already in use"
    
    # Check what's using the port
    PROCESS_INFO=$(lsof -i :$PORT | tail -n +2)
    print_status "Port $PORT is being used by:"
    echo "$PROCESS_INFO"
    
    if [[ $PORT -eq $DEFAULT_PORT ]]; then
        print_status "Trying fallback port $FALLBACK_PORT..."
        if check_port $FALLBACK_PORT; then
            PORT=$FALLBACK_PORT
            print_status "Using port $PORT instead"
        else
            print_error "Fallback port $FALLBACK_PORT is also in use"
            print_status "Please specify a different port: ./start-app.sh [PORT]"
            print_status "Or stop the process using port $DEFAULT_PORT"
            exit 1
        fi
    else
        print_error "Specified port $PORT is in use"
        print_status "Please choose a different port or stop the process using port $PORT"
        exit 1
    fi
else
    print_status "Port $PORT is available"
fi

# Create necessary directories
print_step "Setting up directories..."

if [ ! -d "logs" ]; then
    mkdir -p logs
    print_status "Created logs directory"
else
    print_status "Logs directory already exists"
fi

# Check if we need to add packages (from original startup.sh)
print_step "Checking required packages..."

# Note: Datadog packages were removed as they're not actually used in the code
# This application only tests connectivity to Datadog websites, not implement tracing

# Serilog packages should already be in .csproj, but let's verify they're available
print_status "Verifying Serilog packages..."
if ! grep -q "Serilog.AspNetCore" DatadogChecker.csproj; then
    print_status "Adding Serilog packages..."
    dotnet add package Serilog.AspNetCore
    dotnet add package Serilog.Sinks.Console
    dotnet add package Serilog.Sinks.File
else
    print_status "Serilog packages already present in project file"
fi

# Clean and build (from original run-local.sh)
print_step "Cleaning project..."
dotnet clean
print_status "Project cleaned"

print_step "Removing build artifacts..."
rm -rf bin obj
print_status "Build artifacts removed"

print_step "Restoring packages..."
dotnet restore
if [ $? -eq 0 ]; then
    print_status "Package restore completed successfully"
else
    print_error "Package restore failed"
    exit 1
fi

print_step "Building project..."
dotnet build
if [ $? -eq 0 ]; then
    print_status "Build completed successfully"
else
    print_error "Build failed"
    exit 1
fi

# Display application info
echo
print_step "Starting application..."
print_status "Application: DatadogChecker"
print_status "Port: $PORT"
print_status "Environment: Development"
print_status "Logs: ./logs/"
print_status "Health Check: http://localhost:$PORT/health"
print_status "API Endpoints:"
echo "  - GET  /health"
echo "  - POST /api/status/check-datadog"
echo "  - POST /api/status/check-datacat"
echo "  - GET  /api/status/traces"
echo "  - GET  /api/status/debug"
echo "  - Static files: http://localhost:$PORT/"

# Set environment variables for local development
export ASPNETCORE_ENVIRONMENT=Development

echo
print_status "Press Ctrl+C to stop the application"
echo -e "${GREEN}===============================================${NC}"

# Run the application with the specified port
# Override the hardcoded port in Program.cs by using --urls
dotnet run --urls="http://localhost:$PORT"

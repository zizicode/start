#!/bin/bash

# Quick deployment script - runs everything in sequence
# This is the main script to run after initial setup

set -e

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_status "Starting quick deployment..."

# Make scripts executable
chmod +x scripts/*.sh
chmod +x deploy.sh

# Create secrets
print_status "Setting up secrets..."
./scripts/create-secrets.sh

# Run main deployment
print_status "Running main deployment..."
./deploy.sh

# Check deployment status
print_status "Checking deployment status..."
sleep 10
./scripts/check-deployment.sh

print_success "Quick deployment completed!"
print_warning "Don't forget to:"
echo "  1. Configure your Cloudflare tunnel with the domains"
echo "  2. Update your DNS records to point to the tunnel"
echo "  3. Check that all services are accessible via HTTPS"

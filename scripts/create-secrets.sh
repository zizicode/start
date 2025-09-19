#!/bin/bash

# Script to create necessary secrets for services

set -e

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

# Create secrets directory
mkdir -p secrets

# Create Portainer admin password
if [ ! -f secrets/portainer_admin_password.txt ]; then
    print_status "Creating Portainer admin password..."
    echo "admin123" > secrets/portainer_admin_password.txt
    chmod 600 secrets/portainer_admin_password.txt
    print_success "Portainer admin password created"
else
    print_status "Portainer admin password already exists"
fi

# Create cloudflared directory
mkdir -p cloudflared

print_success "Secrets setup completed"
print_status "Remember to:"
echo "  1. Update secrets/portainer_admin_password.txt with your desired password"
echo "  2. Add your tunnel credentials to cloudflared/credentials.json"
echo "  3. Update TUNNEL_ID in your .env file"

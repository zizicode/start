#!/bin/bash

# Service Status Checker
# Verifies all installed services are running correctly

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_header() {
    echo -e "\n${BLUE}=== $1 ===${NC}"
}

print_status() {
    if [ $1 -eq 0 ]; then
        echo -e "${GREEN}✓${NC} $2"
    else
        echo -e "${RED}✗${NC} $2"
    fi
}

print_header "TAILSCALE STATUS"
if command -v tailscale &> /dev/null; then
    tailscale status
    print_status $? "Tailscale service"
else
    print_status 1 "Tailscale not installed"
fi

print_header "SSH STATUS"
if systemctl is-active --quiet ssh; then
    print_status 0 "SSH service is running"
    echo "SSH is listening on:"
    ss -tlnp | grep :22
else
    print_status 1 "SSH service is not running"
fi

print_header "DOCKER STATUS"
if systemctl is-active --quiet docker; then
    print_status 0 "Docker service is running"
    echo "Docker version: $(docker --version)"
    echo "Docker Compose version: $(docker-compose --version)"
    echo -e "\nRunning containers:"
    docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
else
    print_status 1 "Docker service is not running"
fi

print_header "CLOUDFLARED STATUS"
if docker ps | grep -q cloudflared; then
    print_status 0 "Cloudflared container is running"
    echo -e "\nCloudflared logs (last 10 lines):"
    docker logs --tail 10 cloudflared-tunnel
else
    print_status 1 "Cloudflared container is not running"
fi

print_header "NETWORK STATUS"
echo "Docker networks:"
docker network ls | grep tunnel-net
print_status $? "tunnel-net network exists"

echo -e "\nFirewall status:"
sudo ufw status | grep -E "(22|ssh)"

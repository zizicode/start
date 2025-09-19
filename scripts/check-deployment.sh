#!/bin/bash

# Script to check the status of all deployed services

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
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

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_status "Checking deployment status..."
echo ""

# Check Docker daemon
if ! docker info >/dev/null 2>&1; then
    print_error "Docker is not running"
    exit 1
fi

print_success "Docker daemon is running"

# Check networks
print_status "Checking Docker networks..."
if docker network ls | grep -q tunnel-net; then
    print_success "tunnel-net network exists"
else
    print_error "tunnel-net network not found"
fi

if docker network ls | grep -q db-net; then
    print_success "db-net network exists"
else
    print_warning "db-net network not found (will be created automatically)"
fi

# Check running containers
print_status "Checking container status..."
containers=("postgres" "pgladmin" "portainer" "api" "cloudflared-tunnel")

for container in "${containers[@]}"; do
    if docker ps --format "table {{.Names}}\t{{.Status}}" | grep -q "$container"; then
        status=$(docker ps --format "table {{.Names}}\t{{.Status}}" | grep "$container" | awk '{print $2, $3, $4}')
        print_success "$container: $status"
    else
        print_error "$container: Not running"
    fi
done

echo ""
print_status "Service URLs:"
echo "  🌐 API: https://api.rodolfocordones.com"
echo "  🐳 Portainer: https://docker.rodolfocordones.com"
echo "  🗄️  pgAdmin: https://pgladmin.rodolfocordones.com"

echo ""
print_status "Local URLs (for testing):"
echo "  📊 Portainer: http://localhost:9000"
echo "  🗄️  pgAdmin: http://localhost:5050"
echo "  🔌 API: http://localhost:4000"

echo ""
print_status "Checking service health..."

# Check API health
if curl -f -s http://localhost:4000/health >/dev/null 2>&1; then
    print_success "API health check passed"
else
    print_warning "API health check failed (service may still be starting)"
fi

# Check PostgreSQL connection
if docker exec postgres pg_isready -U postgres >/dev/null 2>&1; then
    print_success "PostgreSQL is ready"
else
    print_warning "PostgreSQL is not ready"
fi

echo ""
print_status "Recent container logs (last 10 lines):"
for container in "${containers[@]}"; do
    if docker ps --format "{{.Names}}" | grep -q "$container"; then
        echo ""
        echo "=== $container logs ==="
        docker logs --tail 10 "$container" 2>/dev/null || print_warning "Could not fetch logs for $container"
    fi
done

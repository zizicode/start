#!/bin/bash

# Deployment Script for Backend API and Services
# Downloads GitHub repo, builds images, and deploys all services

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
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

# Check if running as root
if [[ $EUID -eq 0 ]]; then
   print_error "This script should not be run as root. Please run as a regular user with sudo privileges."
   exit 1
fi

# Load environment variables
if [ -f .env ]; then
    export $(cat .env | grep -v '^#' | xargs)
    print_status "Environment variables loaded from .env file"
else
    print_error ".env file not found. Please create one based on .env.example"
    exit 1
fi

# Validate required environment variables
required_vars=("GITHUB_REPO_URL" "POSTGRES_DB" "POSTGRES_USER" "POSTGRES_PASSWORD" "PGADMIN_EMAIL" "PGADMIN_PASSWORD")
for var in "${required_vars[@]}"; do
    if [ -z "${!var}" ]; then
        print_error "$var is required in .env file"
        exit 1
    fi
done

print_status "Starting deployment process..."

# Step 1: Handle Backend Repository
REPO_DIR="rc_backend_api"
print_status "Managing backend repository..."

if [ -d "$REPO_DIR" ]; then
    print_warning "Directory $REPO_DIR exists. Removing and re-cloning..."
    rm -rf "$REPO_DIR"
fi

print_status "Cloning repository from $GITHUB_REPO_URL..."
git clone "$GITHUB_REPO_URL" "$REPO_DIR"

if [ ! -d "$REPO_DIR" ]; then
    print_error "Failed to clone repository"
    exit 1
fi

print_success "Repository cloned successfully"

# Step 2: Build Backend Docker Image
print_status "Building backend Docker image..."
cd "$REPO_DIR"

if [ ! -f "Dockerfile" ]; then
    print_error "Dockerfile not found in $REPO_DIR"
    exit 1
fi

docker build -t rc-backend-api:latest .
print_success "Backend Docker image built successfully"

cd ..

# Step 3: Deploy Database Services (PostgreSQL + pgAdmin)
print_status "Deploying database services..."
docker-compose -f docker-compose.db.yml up -d

# Wait for PostgreSQL to be ready
print_status "Waiting for PostgreSQL to be ready..."
sleep 10

# Step 4: Deploy Management Services (Portainer)
print_status "Deploying management services..."
docker-compose -f docker-compose.management.yml up -d

# Step 5: Deploy Backend API
print_status "Deploying backend API..."
docker-compose -f docker-compose.api.yml up -d

# Step 6: Deploy Cloudflared with full configuration
print_status "Deploying Cloudflared tunnel..."
docker-compose -f docker-compose.tunnel.yml up -d

# Step 7: Verify all services
print_status "Verifying deployed services..."
sleep 5

services=("postgres" "pgadmin" "portainer" "api" "cloudflared-tunnel")
for service in "${services[@]}"; do
    if docker ps --format "table {{.Names}}" | grep -q "$service"; then
        print_success "$service is running"
    else
        print_error "$service failed to start"
    fi
done

print_success "Deployment completed!"
print_status "Services available at:"
echo "  🌐 API: https://api.rodolfocordones.com"
echo "  🐳 Portainer: https://docker.rodolfocordones.com"
echo "  🗄️  pgAdmin: https://pgadmin.rodolfocordones.com"
echo ""
print_status "Local access (if needed):"
echo "  📊 Portainer: http://localhost:9000"
echo "  🗄️  pgAdmin: http://localhost:5050"
echo "  🔌 API: http://localhost:4000"
echo "  🗃️  PostgreSQL: localhost:5432"

print_warning "Make sure your Cloudflare tunnel is properly configured with the provided token"

#!/bin/bash

# Ubuntu Server Setup Script
# Configures Tailscale, OpenSSH, Docker, and Cloudflared

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
if [ -z "$TAILSCALE_AUTH_KEY" ]; then
    print_error "TAILSCALE_AUTH_KEY is required in .env file"
    exit 1
fi

if [ -z "$CLOUDFLARED_TOKEN" ]; then
    print_error "CLOUDFLARED_TOKEN is required in .env file"
    exit 1
fi

print_status "Starting Ubuntu Server setup..."

# Update system packages
print_status "Updating system packages..."
sudo apt update && sudo apt upgrade -y
print_success "System packages updated"

# Install Tailscale
print_status "Installing and configuring Tailscale..."
if ! command -v tailscale &> /dev/null; then
    curl -fsSL https://tailscale.com/install.sh | sh
    print_success "Tailscale installed"
else
    print_warning "Tailscale already installed"
fi

# Connect to Tailscale
print_status "Connecting to Tailscale network..."
sudo tailscale up --authkey="$TAILSCALE_AUTH_KEY" --accept-routes
if [ $? -eq 0 ]; then
    print_success "Successfully connected to Tailscale network"
    tailscale status
else
    print_error "Failed to connect to Tailscale network"
    exit 1
fi

# Install and configure OpenSSH
print_status "Checking OpenSSH installation..."
if ! command -v sshd &> /dev/null; then
    print_status "Installing OpenSSH server..."
    sudo apt install -y openssh-server
    print_success "OpenSSH server installed"
else
    print_warning "OpenSSH server already installed"
fi

# Enable and start SSH service
print_status "Configuring SSH service..."
sudo systemctl enable ssh
sudo systemctl start ssh

# Configure SSH (backup original config first)
if [ ! -f /etc/ssh/sshd_config.backup ]; then
    sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config.backup
    print_status "SSH config backed up"
fi

# Ensure SSH is listening on port 22
sudo sed -i 's/#Port 22/Port 22/' /etc/ssh/sshd_config
sudo sed -i 's/Port [0-9]*/Port 22/' /etc/ssh/sshd_config

# Enable SSH through firewall
print_status "Configuring firewall for SSH..."
sudo ufw allow 22/tcp
sudo systemctl reload ssh
print_success "SSH configured and enabled on port 22"

# Install Docker
print_status "Installing Docker..."
if ! command -v docker &> /dev/null; then
    # Add Docker's official GPG key
    sudo apt install -y ca-certificates curl gnupg lsb-release
    sudo mkdir -p /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    
    # Add Docker repository
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    
    # Install Docker
    sudo apt update
    sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    
    # Add user to docker group
    sudo usermod -aG docker $USER
    print_success "Docker installed successfully"
else
    print_warning "Docker already installed"
fi

# Install Docker Compose (standalone)
print_status "Installing Docker Compose..."
if ! command -v docker-compose &> /dev/null; then
    sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
    print_success "Docker Compose installed"
else
    print_warning "Docker Compose already installed"
fi

# Start Docker service
sudo systemctl enable docker
sudo systemctl start docker

# Create Docker network for Cloudflared
print_status "Creating Docker network 'tunnel-net'..."
if ! docker network ls | grep -q tunnel-net; then
    docker network create tunnel-net
    print_success "Docker network 'tunnel-net' created"
else
    print_warning "Docker network 'tunnel-net' already exists"
fi

# Deploy Cloudflared container
print_status "Deploying Cloudflared container..."
docker-compose up -d

# Verify Cloudflared is running
sleep 5
if docker ps | grep -q cloudflared; then
    print_success "Cloudflared container is running"
    docker logs cloudflared-tunnel
else
    print_error "Cloudflared container failed to start"
    docker-compose logs
fi

print_success "Ubuntu Server setup completed successfully!"
print_status "Summary of installed services:"
echo "  ✓ Tailscale - Connected to your network"
echo "  ✓ OpenSSH - Enabled on port 22"
echo "  ✓ Docker & Docker Compose - Ready for containers"
echo "  ✓ Cloudflared - Tunnel established"

print_warning "Please log out and log back in for Docker group changes to take effect"
print_status "You can check service status with:"
echo "  - tailscale status"
echo "  - sudo systemctl status ssh"
echo "  - docker ps"
echo "  - docker-compose ps"

#!/bin/bash
# setup-server.sh - Script principal de instalación

set -euo pipefail

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Función para logging
log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')] $1${NC}"
}

error() {
    echo -e "${RED}[ERROR] $1${NC}" >&2
}

warning() {
    echo -e "${YELLOW}[WARNING] $1${NC}"
}

info() {
    echo -e "${BLUE}[INFO] $1${NC}"
}

# Verificar si es root
if [[ $EUID -eq 0 ]]; then
    error "Este script no debe ejecutarse como root. Usa sudo solo cuando sea necesario."
    exit 1
fi

# Verificar Ubuntu
if ! grep -q "Ubuntu" /etc/os-release; then
    error "Este script está diseñado para Ubuntu Server."
    exit 1
fi

log "=== Iniciando configuración del servidor Ubuntu con Tailscale ==="

# 1. Actualizar sistema
log "Actualizando sistema..."
sudo apt update && sudo apt upgrade -y

# 2. Instalar dependencias básicas
log "Instalando dependencias básicas..."
sudo apt install -y \
    curl \
    wget \
    git \
    htop \
    unzip \
    software-properties-common \
    apt-transport-https \
    ca-certificates \
    gnupg \
    lsb-release \
    ufw \
    fail2ban

# 3. Configurar firewall
log "Configurando firewall UFW..."
sudo ufw --force reset
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow ssh
sudo ufw allow 3001/tcp comment 'RC-APP-API-V1'
sudo ufw allow 9000/tcp comment 'Portainer'
sudo ufw allow 9443/tcp comment 'Portainer HTTPS'
sudo ufw allow 80/tcp comment 'HTTP'
sudo ufw allow 443/tcp comment 'HTTPS'
sudo ufw --force enable

# 4. Instalar Docker
log "Instalando Docker..."
if ! command -v docker &> /dev/null; then
    curl -fsSL https://get.docker.com -o get-docker.sh
    sudo sh get-docker.sh
    sudo usermod -aG docker $USER
    rm get-docker.sh
    log "Docker instalado correctamente"
else
    warning "Docker ya está instalado"
fi

# 5. Instalar Docker Compose
log "Instalando Docker Compose..."
if ! command -v docker-compose &> /dev/null; then
    DOCKER_COMPOSE_VERSION=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep tag_name | cut -d '"' -f 4)
    sudo curl -L "https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
    log "Docker Compose ${DOCKER_COMPOSE_VERSION} instalado"
else
    warning "Docker Compose ya está instalado"
fi

# 6. Instalar Tailscale
log "Ejecutando instalación de Tailscale..."
if [ -f "./scripts/install-tailscale.sh" ]; then
    chmod +x ./scripts/install-tailscale.sh
    sudo ./scripts/install-tailscale.sh
else
    error "Script install-tailscale.sh no encontrado"
    exit 1
fi

# 7. Verificar archivo .env
log "Verificando configuración..."
if [ ! -f ".env" ]; then
    warning "Archivo .env no encontrado. Copiando desde .env.example"
    if [ -f ".env.example" ]; then
        cp .env.example .env
        warning "¡IMPORTANTE! Edita el archivo .env con tus configuraciones antes de continuar"
        info "Especialmente configura TS_AUTHKEY con tu auth key de Tailscale"
        read -p "¿Has configurado el archivo .env? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            warning "Configuración pausada. Edita .env y vuelve a ejecutar el script"
            exit 0
        fi
    else
        error "Archivo .env.example no encontrado"
        exit 1
    fi
fi

# 8. Crear directorios necesarios
log "Creando estructura de directorios..."
mkdir -p ./portainer_data
mkdir -p ./nginx/logs
mkdir -p ./api/logs
mkdir -p ./api/uploads
mkdir -p /var/lib/tailscale

# 9. Configurar permisos
log "Configurando permisos..."
sudo chown -R $USER:$USER ./portainer_data
sudo chown -R $USER:$USER ./nginx/logs
sudo chown -R $USER:$USER ./api

# 10. Inicializar servicios Docker
log "Iniciando servicios Docker..."
if [ -f "docker-compose.yml" ]; then
    # Crear red si no existe
    docker network create tailscale-network 2>/dev/null || true
    
    # Iniciar servicios
    docker-compose up -d
    
    log "Esperando que los servicios se inicialicen..."
    sleep 30
    
    # Verificar estado de servicios
    docker-compose ps
else
    error "Archivo docker-compose.yml no encontrado"
    exit 1
fi

# 11. Mostrar información de conexión
log "=== Configuración inicial completada ==="
info "Servicios configurados:"
info "- API: http://localhost:3001"
info "- Portainer: http://localhost:9000"
info "- Nginx Proxy: http://localhost:80"

warning "PRÓXIMOS PASOS:"
info "1. Ejecuta: sudo tailscale status"
info "2. Si Tailscale no está conectado, ejecuta: sudo tailscale up --authkey=TU_AUTH_KEY"
info "3. Ejecuta el script de configuración de Funnel: sudo ./scripts/configure-funnel.sh"
info "4. Accede a Portainer en http://localhost:9000 para configurar el admin inicial"

log "=== Instalación completada exitosamente ==="
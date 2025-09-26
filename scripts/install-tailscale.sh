#!/bin/bash
# install-tailscale.sh - Instalación de Tailscale

set -euo pipefail

log() {
    echo -e "\033[0;32m[$(date +'%Y-%m-%d %H:%M:%S')] $1\033[0m"
}

error() {
    echo -e "\033[0;31m[ERROR] $1\033[0m" >&2
}

log "Instalando Tailscale..."

# Verificar si ya está instalado
if command -v tailscale &> /dev/null; then
    log "Tailscale ya está instalado. Versión: $(tailscale version)"
    exit 0
fi

# Instalar Tailscale usando el script oficial
log "Descargando e instalando Tailscale..."
curl -fsSL https://tailscale.com/install.sh | sh

# Verificar instalación
if command -v tailscale &> /dev/null; then
    log "Tailscale instalado correctamente"
    tailscale version
    
    # Habilitar servicio
    sudo systemctl enable tailscaled
    sudo systemctl start tailscaled
    
    log "Servicio tailscaled iniciado y habilitado"
    
    # Mostrar estado
    sudo systemctl status tailscaled --no-pager
else
    error "Error en la instalación de Tailscale"
    exit 1
fi
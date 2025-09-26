#!/bin/bash
# configure-funnel.sh - Configuración de Tailscale Serve y Funnel

set -euo pipefail

log() {
    echo -e "\033[0;32m[$(date +'%Y-%m-%d %H:%M:%S')] $1\033[0m"
}

error() {
    echo -e "\033[0;31m[ERROR] $1\033[0m" >&2
}

warning() {
    echo -e "\033[1;33m[WARNING] $1\033[0m"
}

info() {
    echo -e "\033[0;34m[INFO] $1\033[0m"
}

log "=== Configurando Tailscale Serve y Funnel ==="

# Verificar que Tailscale esté instalado y conectado
if ! command -v tailscale &> /dev/null; then
    error "Tailscale no está instalado"
    exit 1
fi

# Verificar conexión
if ! sudo tailscale status &> /dev/null; then
    error "Tailscale no está conectado. Ejecuta: sudo tailscale up --authkey=tskey-auth-kNwEyuyuMs11CNTRL-QVbV7bvN4B1Jr9pXa9XNB1Snp9KmRMY6"
    exit 1
fi

# Obtener información del nodo
TAILSCALE_IP=$(sudo tailscale ip -4)
TAILSCALE_HOSTNAME=$(sudo tailscale status --json | jq -r '.Self.DNSName' | sed 's/\.$//')

log "Configuración actual de Tailscale:"
info "IP: $TAILSCALE_IP"
info "Hostname: $TAILSCALE_HOSTNAME"

# Leer variables del .env si existe
if [ -f ".env" ]; then
    export $(grep -v '^#' .env | xargs)
fi

API_PORT=${API_PORT:-3001}
PORTAINER_PORT=${PORTAINER_PORT:-9000}

# Verificar que los servicios estén ejecutándose
log "Verificando servicios locales..."

if ! curl -f http://localhost:$API_PORT/health &>/dev/null; then
    warning "API no responde en puerto $API_PORT. Verificando con curl básico..."
    if ! curl -f http://localhost:$API_PORT &>/dev/null; then
        error "API no está disponible en puerto $API_PORT"
        info "Verifica que el contenedor esté ejecutándose: docker-compose ps"
        exit 1
    fi
fi

if ! curl -f http://localhost:$PORTAINER_PORT &>/dev/null; then
    warning "Portainer no responde en puerto $PORTAINER_PORT"
    info "Verifica que Portainer esté ejecutándose: docker-compose ps"
fi

# Configurar Tailscale Serve para la API
log "Configurando Tailscale Serve para API en puerto $API_PORT..."
sudo tailscale serve https:443 http://localhost:$API_PORT

# Configurar Tailscale Serve para Portainer
log "Configurando Tailscale Serve para Portainer en puerto $PORTAINER_PORT..."
sudo tailscale serve https:8443 http://localhost:$PORTAINER_PORT

# Mostrar configuración actual de Serve
log "Configuración actual de Tailscale Serve:"
sudo tailscale serve status

# Preguntar si activar Funnel
echo
read -p "¿Deseas activar Tailscale Funnel para hacer los servicios públicos? (y/N): " -n 1 -r
echo

if [[ $REPLY =~ ^[Yy]$ ]]; then
    warning "IMPORTANTE: Esto hará que tus servicios sean accesibles públicamente desde Internet"
    echo
    read -p "¿Estás seguro? (y/N): " -n 1 -r
    echo
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        log "Activando Tailscale Funnel..."
        
        # Activar Funnel para API (puerto 443)
        sudo tailscale funnel 443 on
        
        # Activar Funnel para Portainer (puerto 8443)
        sudo tailscale funnel 8443 on
        
        log "Tailscale Funnel activado!"
        
        # Mostrar URLs públicas
        echo
        log "=== URLs PÚBLICAS DISPONIBLES ==="
        info "API: https://$TAILSCALE_HOSTNAME"
        info "Portainer: https://$TAILSCALE_HOSTNAME:8443"
        echo
        warning "Estos servicios ahora son accesibles públicamente desde Internet"
        
        # Mostrar estado de Funnel
        log "Estado de Tailscale Funnel:"
        sudo tailscale funnel status
    else
        info "Funnel no activado. Los servicios solo están disponibles en tu tailnet privado"
    fi
else
    info "Funnel no activado. Los servicios solo están disponibles en tu tailnet privado"
    echo
    log "=== URLs PRIVADAS (SOLO EN TU TAILNET) ==="
    info "API: https://$TAILSCALE_HOSTNAME"
    info "Portainer: https://$TAILSCALE_HOSTNAME:8443"
fi

echo
log "=== Comandos útiles ==="
info "Ver estado de Tailscale: sudo tailscale status"
info "Ver configuración de Serve: sudo tailscale serve status"
info "Ver configuración de Funnel: sudo tailscale funnel status"
info "Desactivar Funnel: sudo tailscale funnel 443 off && sudo tailscale funnel 8443 off"
info "Reset configuración Serve: sudo tailscale serve reset"

log "=== Configuración de Tailscale completada ==="
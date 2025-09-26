#!/bin/bash

set -euo pipefail

# Colores
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

log() { echo -e "${GREEN}[$(date +'%H:%M:%S')] $1${NC}"; }
warning() { echo -e "${YELLOW}[WARNING] $1${NC}"; }
error() { echo -e "${RED}[ERROR] $1${NC}"; }

show_help() {
    echo "Uso: $0 [COMANDO]"
    echo ""
    echo "Comandos disponibles:"
    echo "  start     - Iniciar todos los servicios"
    echo "  stop      - Detener todos los servicios"
    echo "  restart   - Reiniciar todos los servicios"
    echo "  status    - Mostrar estado de servicios"
    echo "  logs      - Mostrar logs de todos los servicios"
    echo "  logs-api  - Mostrar logs solo del API"
    echo "  update    - Actualizar imágenes y reiniciar"
    echo "  clean     - Limpiar contenedores y volúmenes no utilizados"
    echo "  backup    - Crear backup de configuraciones"
    echo "  tailscale - Mostrar estado de Tailscale"
    echo "  help      - Mostrar esta ayuda"
}

start_services() {
    log "Iniciando servicios..."
    docker-compose up -d
    log "Servicios iniciados"
    show_status
}

stop_services() {
    log "Deteniendo servicios..."
    docker-compose down
    log "Servicios detenidos"
}

restart_services() {
    log "Reiniciando servicios..."
    docker-compose restart
    log "Servicios reiniciados"
    show_status
}

show_status() {
    log "Estado de servicios Docker:"
    docker-compose ps
    echo ""
    log "Estado de Tailscale:"
    sudo tailscale status --peers=false || warning "Tailscale no disponible"
}

show_logs() {
    if [ "${1:-}" = "api" ]; then
        docker-compose logs -f api
    else
        docker-compose logs -f
    fi
}

update_services() {
    log "Actualizando servicios..."
    docker-compose pull
    docker-compose up -d
    log "Servicios actualizados"
    show_status
}

clean_docker() {
    log "Limpiando recursos Docker no utilizados..."
    docker system prune -af --volumes
    log "Limpieza completada"
}

create_backup() {
    BACKUP_FILE="tailscale-server-backup-$(date +%Y%m%d_%H%M%S).tar.gz"
    log "Creando backup: $BACKUP_FILE"
    
    tar -czf "$BACKUP_FILE" \
        --exclude='./portainer_data' \
        --exclude='./nginx/logs' \
        --exclude='./api/logs' \
        --exclude='./api/node_modules' \
        .
    
    log "Backup creado: $BACKUP_FILE"
}

show_tailscale() {
    log "Estado completo de Tailscale:"
    sudo tailscale status
    echo ""
    log "Configuración de Serve:"
    sudo tailscale serve status || warning "Serve no configurado"
    echo ""
    log "Configuración de Funnel:"
    sudo tailscale funnel status || warning "Funnel no configurado"
}

# Verificar que estamos en el directorio correcto
if [ ! -f "docker-compose.yml" ]; then
    error "docker-compose.yml no encontrado. Ejecuta desde el directorio raíz del proyecto."
    exit 1
fi

# Procesamiento de comandos
case "${1:-help}" in
    start)
        start_services
        ;;
    stop)
        stop_services
        ;;
    restart)
        restart_services
        ;;
    status)
        show_status
        ;;
    logs)
        show_logs "${2:-}"
        ;;
    logs-api)
        show_logs "api"
        ;;
    update)
        update_services
        ;;
    clean)
        clean_docker
        ;;
    backup)
        create_backup
        ;;
    tailscale)
        show_tailscale
        ;;
    help|--help|-h)
        show_help
        ;;
    *)
        error "Comando desconocido: $1"
        show_help
        exit 1
        ;;
esac
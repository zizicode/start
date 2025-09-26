#!/bin/bash

set -euo pipefail

# Colores
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Cargar variables del .env
if [ -f ".env" ]; then
    export $(grep -v '^#' .env | xargs)
fi

API_PORT=${API_PORT:-3001}
PORTAINER_PORT=${PORTAINER_PORT:-9000}

check_service() {
    local service_name=$1
    local url=$2
    local expected_status=${3:-200}
    
    echo -n "Verificando $service_name... "
    
    if curl -s -o /dev/null -w "%{http_code}" "$url" | grep -q "$expected_status"; then
        echo -e "${GREEN}✓ OK${NC}"
        return 0
    else
        echo -e "${RED}✗ FAIL${NC}"
        return 1
    fi
}

check_docker_service() {
    local container_name=$1
    echo -n "Verificando contenedor $container_name... "
    
    if docker ps --format "table {{.Names}}" | grep -q "$container_name"; then
        echo -e "${GREEN}✓ Ejecutándose${NC}"
        return 0
    else
        echo -e "${RED}✗ No encontrado${NC}"
        return 1
    fi
}

echo -e "${BLUE}=== Health Check de Servicios ===${NC}"
echo ""

# Verificar contenedores Docker
echo -e "${YELLOW}Verificando contenedores Docker:${NC}"
check_docker_service "rc-app-api-v1" || API_CONTAINER_FAIL=1
check_docker_service "portainer" || PORTAINER_CONTAINER_FAIL=1
check_docker_service "nginx-proxy" || NGINX_CONTAINER_FAIL=1
check_docker_service "tailscale-client" || TAILSCALE_CONTAINER_FAIL=1

echo ""

# Verificar servicios HTTP
echo -e "${YELLOW}Verificando servicios HTTP:${NC}"
check_service "API" "http://localhost:$API_PORT" || API_HTTP_FAIL=1
check_service "API Health" "http://localhost:$API_PORT/health" || API_HEALTH_FAIL=1
check_service "Portainer" "http://localhost:$PORTAINER_PORT" || PORTAINER_HTTP_FAIL=1
check_service "Nginx Proxy" "http://localhost:80/nginx-health" || NGINX_HTTP_FAIL=1

echo ""

# Verificar Tailscale
echo -e "${YELLOW}Verificando Tailscale:${NC}"
echo -n "Estado de conexión... "
if sudo tailscale status &>/dev/null; then
    echo -e "${GREEN}✓ Conectado${NC}"
    
    # Mostrar IP de Tailscale
    TAILSCALE_IP=$(sudo tailscale ip -4 2>/dev/null || echo "N/A")
    echo "IP de Tailscale: $TAILSCALE_IP"
    
    # Verificar Serve
    echo -n "Configuración de Serve... "
    if sudo tailscale serve status &>/dev/null; then
        echo -e "${GREEN}✓ Configurado${NC}"
    else
        echo -e "${YELLOW}! No configurado${NC}"
    fi
    
    # Verificar Funnel
    echo -n "Estado de Funnel... "
    if sudo tailscale funnel status 2>/dev/null | grep -q "Funnel on"; then
        echo -e "${GREEN}✓ Activo${NC}"
    else
        echo -e "${YELLOW}! Inactivo${NC}"
    fi
else
    echo -e "${RED}✗ Desconectado${NC}"
    TAILSCALE_FAIL=1
fi

echo ""

# Resumen
echo -e "${BLUE}=== Resumen ===${NC}"
TOTAL_FAILS=$((\
    ${API_CONTAINER_FAIL:-0} + \
    ${PORTAINER_CONTAINER_FAIL:-0} + \
    ${NGINX_CONTAINER_FAIL:-0} + \
    ${TAILSCALE_CONTAINER_FAIL:-0} + \
    ${API_HTTP_FAIL:-0} + \
    ${API_HEALTH_FAIL:-0} + \
    ${PORTAINER_HTTP_FAIL:-0} + \
    ${NGINX_HTTP_FAIL:-0} + \
    ${TAILSCALE_FAIL:-0}\
))

if [ $TOTAL_FAILS -eq 0 ]; then
    echo -e "${GREEN}✓ Todos los servicios están funcionando correctamente${NC}"
    exit 0
else
    echo -e "${RED}✗ Se encontraron $TOTAL_FAILS problemas${NC}"
    echo ""
    echo "Comandos útiles para diagnóstico:"
    echo "- Ver logs: docker-compose logs -f"
    echo "- Estado de contenedores: docker-compose ps"
    echo "- Estado de Tailscale: sudo tailscale status"
    echo "- Reiniciar servicios: docker-compose restart"
    exit 1
fi
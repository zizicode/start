#!/usr/bin/env bash
set -euo pipefail

# -------------------------
# Configuración de archivos docker-compose por servicio
# -------------------------
BASE_COMPOSE="-f docker-compose.base.yml"
declare -A SERVICES
SERVICES=(
  ["api"]="-f docker-compose.api.yml"
  ["pgadmin"]="-f docker-compose.pgadmin.yml"
  ["portainer"]="-f docker-compose.portainer.yml"
  ["cloudflared"]="-f docker-compose.cloudflared.yml"
)

# -------------------------
# Funciones
# -------------------------
function usage() {
  echo "Uso: $0 {up|down|restart|rebuild} [servicio]"
  echo "Servicios disponibles: api, pgadmin, portainer, cloudflared, all"
  exit 1
}

# Levantar contenedor(s)
function compose_up() {
  local service=$1
  if [[ "$service" == "all" ]]; then
    docker-compose $BASE_COMPOSE \
      -f docker-compose.api.yml \
      -f docker-compose.pgadmin.yml \
      -f docker-compose.portainer.yml \
      -f docker-compose.cloudflared.yml up -d
  else
    if [[ -v SERVICES[$service] ]]; then
      docker-compose $BASE_COMPOSE ${SERVICES[$service]} up -d
    else
      echo "Servicio desconocido: $service"
      usage
    fi
  fi
}

# Apagar contenedor(s)
function compose_down() {
  local service=$1
  if [[ "$service" == "all" ]]; then
    docker-compose $BASE_COMPOSE \
      -f docker-compose.api.yml \
      -f docker-compose.pgadmin.yml \
      -f docker-compose.portainer.yml \
      -f docker-compose.cloudflared.yml down
  else
    if [[ -v SERVICES[$service] ]]; then
      docker-compose $BASE_COMPOSE ${SERVICES[$service]} down
    else
      echo "Servicio desconocido: $service"
      usage
    fi
  fi
}

# Reiniciar contenedor(s)
function compose_restart() {
  local service=$1
  compose_down "$service"
  compose_up "$service"
}

# Reconstruir contenedor(s) (build y levantar de nuevo)
function compose_rebuild() {
  local service=$1
  if [[ "$service" == "all" ]]; then
    docker-compose $BASE_COMPOSE \
      -f docker-compose.api.yml \
      -f docker-compose.pgadmin.yml \
      -f docker-compose.portainer.yml \
      -f docker-compose.cloudflared.yml down
    docker-compose $BASE_COMPOSE \
      -f docker-compose.api.yml \
      -f docker-compose.pgadmin.yml \
      -f docker-compose.portainer.yml \
      -f docker-compose.cloudflared.yml build --no-cache
    docker-compose $BASE_COMPOSE \
      -f docker-compose.api.yml \
      -f docker-compose.pgadmin.yml \
      -f docker-compose.portainer.yml \
      -f docker-compose.cloudflared.yml up -d
  else
    if [[ -v SERVICES[$service] ]]; then
      docker-compose $BASE_COMPOSE ${SERVICES[$service]} down
      docker-compose $BASE_COMPOSE ${SERVICES[$service]} build --no-cache
      docker-compose $BASE_COMPOSE ${SERVICES[$service]} up -d
    else
      echo "Servicio desconocido: $service"
      usage
    fi
  fi
}

# -------------------------
# Main
# -------------------------
if [[ $# -lt 2 ]]; then
  usage
fi

ACTION=$1
SERVICE=$2

case $ACTION in
  up)
    compose_up "$SERVICE"
    ;;
  down)
    compose_down "$SERVICE"
    ;;
  restart)
    compose_restart "$SERVICE"
    ;;
  rebuild)
    compose_rebuild "$SERVICE"
    ;;
  *)
    usage
    ;;
esac

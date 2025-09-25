#!/bin/bash

# Configuración completa de Tailscale + Docker desde cero
# Para Rodolfo Cordones - rodolfocordones.com

set -e  # Salir si hay algún error

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Función para logs
log() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Verificar que se proporcionó el Auth Key
if [ $# -eq 0 ]; then
    error "Uso: $0 <TAILSCALE_AUTH_KEY>"
    echo "Ejemplo: $0 tskey-auth-kNwEyuyuMs11CNTRL-QVbV7bvN4B1Jr9pXa9XNB1Snp9KmRMY6"
    echo ""
    echo "Para obtener tu Auth Key:"
    echo "1. Ve a https://login.tailscale.com/admin/settings/keys"
    echo "2. Genera una nueva Auth Key"
    echo "3. Cópiala y ejecútala con este script"
    exit 1
fi

TAILSCALE_AUTH_KEY="$1"

log "🚀 Iniciando configuración completa..."
log "Auth Key: ${TAILSCALE_AUTH_KEY:0:20}..."

# Paso 1: Limpiar todo lo existente
log "1. Limpiando configuración anterior..."
docker compose down 2>/dev/null || true
docker stop $(docker ps -aq) 2>/dev/null || true
docker rm $(docker ps -aq) 2>/dev/null || true
docker volume rm $(docker volume ls -q | grep -E "(tailscale|api|portainer)" | head -10) 2>/dev/null || true

# Paso 2: Crear directorios necesarios
log "2. Creando estructura de directorios..."
mkdir -p logs
mkdir -p rc-app-api-v1 2>/dev/null || true

# Paso 3: Verificar que existe la API
if [ ! -d "rc-app-api-v1" ] || [ ! -f "rc-app-api-v1/package.json" ]; then
    warn "No se encontró la API en ./rc-app-api-v1/"
    warn "Por favor asegúrate de que tu API esté en esa carpeta"
    read -p "¿Continuar de todas formas? (y/n): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# Paso 4: Crear Dockerfile optimizado para la API
log "3. Creando Dockerfile para la API..."
cat > rc-app-api-v1/Dockerfile << 'EOF'
# Imagen base
FROM node:20-alpine

# Instalar curl para health checks
RUN apk add --no-cache curl

# Crear directorio de trabajo
WORKDIR /usr/src/app

# Copiar package.json y package-lock.json primero (mejor cache)
COPY package*.json ./

# Instalar dependencias
RUN npm ci --only=production && npm cache clean --force

# Copiar el resto del código
COPY . .

# Compilar TypeScript a JavaScript
RUN npm run build

# Crear usuario no-root para seguridad
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nodejs -u 1001

# Crear directorios necesarios
RUN mkdir -p /usr/src/app/data /usr/src/app/logs && \
    chown -R nodejs:nodejs /usr/src/app

# Cambiar a usuario no-root
USER nodejs

# Exponer el puerto
EXPOSE 3030

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
    CMD curl -f http://localhost:3030/health || curl -f http://localhost:3030/ || exit 1

# Comando para ejecutar (usa la carpeta compilada dist/)
CMD ["node", "dist/server.js"]
EOF

# Paso 5: Crear .dockerignore para optimizar build
log "4. Creando .dockerignore..."
cat > rc-app-api-v1/.dockerignore << 'EOF'
node_modules
npm-debug.log*
.env*
logs
*.log
.tmp
.temp
.DS_Store
Thumbs.db
.git
.gitignore
README.md
docs/
test/
tests/
*.test.js
*.spec.js
coverage/
.nyc_output
EOF

# Paso 6: Crear docker-compose.yml
log "5. Creando docker-compose.yml..."
cat > docker-compose.yml << EOF
version: "3.8"

services:
  # Servicio de Tailscale
  tailscale:
    image: tailscale/tailscale:latest
    hostname: server-rodolfo
    container_name: tailscale-main
    environment:
      - TS_AUTHKEY=$TAILSCALE_AUTH_KEY
      - TS_STATE_DIR=/var/lib/tailscale
      - TS_USERSPACE=true
      - TS_HOSTNAME=server-rodolfo
      - TS_EXTRA_ARGS=--advertise-tags=tag:server --accept-routes
      # Health check y métricas
      - TS_ENABLE_HEALTH_CHECK=true
      - TS_ENABLE_METRICS=true
      - TS_LOCAL_ADDR_PORT=0.0.0.0:9002
    volumes:
      - tailscale_data:/var/lib/tailscale
    cap_add:
      - NET_ADMIN
      - SYS_MODULE
    restart: unless-stopped
    ports:
      - "3030:3030"
      - "9000:9000"
      - "9443:9443"
      - "9002:9002"  # Métricas de Tailscale

  # API de Rodolfo Cordones
  rc-api:
    build:
      context: ./rc-app-api-v1
      dockerfile: Dockerfile
    container_name: rc-api
    environment:
      - NODE_ENV=production
      - PORT=3030
      - API_HOST=0.0.0.0
      - API_PORT=3030
    volumes:
      - api_data:/usr/src/app/data
      - ./logs:/usr/src/app/logs
    network_mode: service:tailscale
    depends_on:
      - tailscale
    restart: unless-stopped

  # Portainer para gestión de Docker
  portainer:
    image: portainer/portainer-ee:latest
    container_name: portainer
    command: -H unix:///var/run/docker.sock
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
      - portainer_data:/data
    network_mode: service:tailscale
    depends_on:
      - tailscale
    restart: unless-stopped

volumes:
  tailscale_data:
    driver: local
  api_data:
    driver: local
  portainer_data:
    driver: local
EOF

log "6. Validando docker-compose.yml..."
if ! docker compose config >/dev/null 2>&1; then
    error "Error en la configuración de docker-compose.yml"
    docker compose config
    exit 1
fi

# Paso 7: Iniciar servicios paso a paso
log "7. Iniciando Tailscale..."
docker compose up tailscale -d

# Esperar a que Tailscale se conecte
log "8. Esperando conexión de Tailscale..."
for i in {1..12}; do
    sleep 5
    echo -n "."
    if docker exec tailscale-main tailscale status >/dev/null 2>&1; then
        echo ""
        log "✅ Tailscale conectado exitosamente"
        break
    fi
    if [ $i -eq 12 ]; then
        echo ""
        error "Tailscale no se pudo conectar después de 60 segundos"
        echo "Logs de Tailscale:"
        docker logs tailscale-main
        exit 1
    fi
done

# Mostrar información de Tailscale
echo ""
log "📍 Estado de Tailscale:"
docker exec tailscale-main tailscale status

# Paso 8: Construir y iniciar API
log "9. Construyendo e iniciando API..."
docker compose up rc-api -d

# Paso 9: Iniciar Portainer
log "10. Iniciando Portainer..."
docker compose up portainer -d

# Esperar a que los servicios estén listos
log "11. Esperando que los servicios estén listos..."
sleep 20

# Verificar estado
log "12. Verificando estado de servicios..."
docker compose ps

# Paso 10: Instalar herramientas en Tailscale para configuración
log "13. Instalando herramientas de red en Tailscale..."
docker exec tailscale-main apk add --no-cache curl wget >/dev/null 2>&1 || warn "No se pudieron instalar herramientas adicionales"

# Paso 11: Configurar Tailscale Serve y Funnel
log "14. Configurando Tailscale Serve..."

# API en puerto 3030
docker exec tailscale-main tailscale serve --bg --port 3030 http://localhost:3030

# Portainer en puerto 9000 (HTTP)
docker exec tailscale-main tailscale serve --bg --port 9000 http://localhost:9000

# Portainer en puerto 9443 (HTTPS)
docker exec tailscale-main tailscale serve --bg --port 9443 https://localhost:9443

log "15. Habilitando Tailscale Funnel para acceso público..."
docker exec tailscale-main tailscale funnel --bg 3030
docker exec tailscale-main tailscale funnel --bg 9000
docker exec tailscale-main tailscale funnel --bg 9443

# Mostrar configuración final
echo ""
log "📊 Configuración de Tailscale Serve:"
docker exec tailscale-main tailscale serve status

echo ""
log "📊 Configuración de Tailscale Funnel:"
docker exec tailscale-main tailscale funnel status

# Información final
echo ""
echo "🎉 ¡Configuración completa!"
echo ""
echo -e "${BLUE}🌐 URLs de acceso directo:${NC}"
echo "🚀 API: https://server-rodolfo.tail406547.ts.net:3030"
echo "🐳 Portainer HTTP: https://server-rodolfo.tail406547.ts.net:9000"
echo "🐳 Portainer HTTPS: https://server-rodolfo.tail406547.ts.net:9443"
echo ""
echo -e "${BLUE}🔗 Para tu configuración de Vercel (rodolfocordones.com):${NC}"
echo "Configura tu proxy JSON con:"
echo "{"
echo '  "api.rodolfocordones.com": "server-rodolfo.tail406547.ts.net:3030",'
echo '  "portainer.rodolfocordones.com": "server-rodolfo.tail406547.ts.net:9000"'
echo "}"
echo ""
echo -e "${GREEN}✅ Todo listo para usar!${NC}"
echo ""
echo "Comandos útiles:"
echo "- Ver logs: docker compose logs -f"
echo "- Ver estado: docker compose ps"
echo "- Reiniciar: docker compose restart"
echo "- Detener: docker compose down"
#!/bin/bash

echo "🚀 Configurando servicios con Tailscale para rodolfocordones.com..."

# Función para esperar que un servicio esté disponible
wait_for_service() {
    local host=$1
    local port=$2
    local service_name=$3
    
    echo "Esperando que $service_name esté disponible en $host:$port..."
    until docker exec tailscale-main wget --quiet --tries=1 --timeout=3 --spider http://$host:$port 2>/dev/null; do
        sleep 2
        echo "Esperando $service_name..."
    done
    echo "✅ $service_name está disponible"
}

# Esperar a que Tailscale se conecte
echo "Esperando conexión de Tailscale..."
sleep 15

# Esperar a que los servicios estén disponibles
wait_for_service "localhost" "3030" "RC API"
wait_for_service "localhost" "9443" "Portainer"

echo "Configurando Tailscale Serve..."

# Configurar API en puerto 3030 (accesible como api.rodolfocordones.com)
echo "Configurando RC API en puerto 3030..."
docker exec tailscale-main tailscale serve --bg --set-path / --port 3030 http://localhost:3030

# Configurar Portainer en puerto 9443 (accesible como portainer.rodolfocordones.com)  
echo "Configurando Portainer en puerto 9443..."
docker exec tailscale-main tailscale serve --bg --set-path / --port 9443 https://localhost:9443

# Habilitar Tailscale Funnel para acceso público
echo "Habilitando Tailscale Funnel..."
docker exec tailscale-main tailscale funnel --bg 3030
docker exec tailscale-main tailscale funnel --bg 9443

# Mostrar estado de los servicios
echo "📊 Estado de Tailscale Serve:"
docker exec tailscale-main tailscale serve status

echo "📊 Estado de Tailscale Funnel:"  
docker exec tailscale-main tailscale funnel status

# Mostrar información de conexión
echo ""
echo "🌐 Tu servidor está disponible en:"
TAILSCALE_IP=$(docker exec tailscale-main tailscale ip -4)
echo "📍 IP de Tailscale: $TAILSCALE_IP"

echo ""
echo "🔗 URLs de acceso:"
echo "🚀 API (puerto 3030): https://server-rodolfo.tail406547.ts.net:3030"
echo "🐳 Portainer (puerto 9443): https://server-rodolfo.tail406547.ts.net:9443"

echo ""
echo "🌍 Con tu configuración de Vercel en rodolfocordones.com:"
echo "🚀 API: https://api.rodolfocordones.com → server.tail406547.ts.net:3030"
echo "🐳 Portainer: https://portainer.rodolfocordones.com → server.tail406547.ts.net:9443"

echo ""
echo "✅ Configuración completa. Verifica que tu proxy en Vercel esté configurado correctamente."
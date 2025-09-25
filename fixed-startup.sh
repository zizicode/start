#!/bin/bash

echo "🚀 Iniciando servicios con configuración corregida..."

# Limpiar contenedores anteriores
echo "1. Limpiando contenedores anteriores..."
docker-compose down
docker rm -f tailscale-main rc-api portainer 2>/dev/null || true

# Verificar que el Auth Key esté configurado
echo "2. Verificando configuración..."
if grep -q "TU-AUTH-KEY-AQUI" docker-compose.yml; then
    echo "❌ Auth Key no actualizado en docker-compose.yml"
    exit 1
fi

# Iniciar solo Tailscale primero para verificar
echo "3. Iniciando Tailscale..."
docker-compose up tailscale -d

# Esperar y verificar logs
echo "4. Esperando que Tailscale se conecte..."
sleep 15

# Verificar que Tailscale esté funcionando
echo "5. Verificando estado de Tailscale..."
if docker exec tailscale-main tailscale status >/dev/null 2>&1; then
    echo "✅ Tailscale conectado exitosamente"
    
    # Mostrar información de conexión
    echo "📍 Información de Tailscale:"
    docker exec tailscale-main tailscale status
    
    # Iniciar el resto de servicios
    echo "6. Iniciando API y Portainer..."
    docker-compose up -d
    
    echo "✅ Todos los servicios iniciados. Esperando que estén listos..."
    sleep 10
    
    # Verificar estado final
    echo "📊 Estado final:"
    docker-compose ps
    
else
    echo "❌ Error en Tailscale. Mostrando logs:"
    docker logs tailscale-main
    echo ""
    echo "Por favor revisa los logs arriba y corrige el problema."
fi
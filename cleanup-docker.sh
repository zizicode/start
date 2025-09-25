#!/bin/bash

echo "🧹 Iniciando limpieza completa de Docker..."

echo "1. Deteniendo todos los contenedores..."
docker stop $(docker ps -aq) 2>/dev/null || echo "No hay contenedores corriendo"

echo "2. Eliminando todos los contenedores..."
docker rm $(docker ps -aq) 2>/dev/null || echo "No hay contenedores para eliminar"

echo "3. Eliminando todas las imágenes..."
docker rmi $(docker images -q) -f 2>/dev/null || echo "No hay imágenes para eliminar"

echo "4. Eliminando todos los volúmenes..."
docker volume rm $(docker volume ls -q) 2>/dev/null || echo "No hay volúmenes para eliminar"

echo "5. Eliminando todas las redes personalizadas..."
docker network rm $(docker network ls -q --filter type=custom) 2>/dev/null || echo "No hay redes personalizadas para eliminar"

echo "6. Limpieza del sistema (prune)..."
docker system prune -a -f --volumes

echo "7. Verificando limpieza..."
echo "Contenedores restantes:"
docker ps -a
echo "Imágenes restantes:"
docker images
echo "Volúmenes restantes:"
docker volume ls
echo "Redes restantes:"
docker network ls

echo "✅ Limpieza completa terminada"
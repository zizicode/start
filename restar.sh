#!/bin/bash
set -e

echo "🔴 Eliminando contenedores en ejecución..."
sudo docker ps -aq | xargs -r sudo docker stop
sudo docker ps -aq | xargs -r sudo docker rm

echo "🟠 Eliminando imágenes del proyecto..."
# Si quieres borrar todas las imágenes, deja este:
sudo docker images -q | xargs -r sudo docker rmi -f
# Si prefieres borrar solo las de tu API:
# sudo docker images | grep "api" | awk '{print $3}' | xargs -r sudo docker rmi -f

echo "🟢 Ejecutando setup.sh..."
chmod +x setud.sh
./setup.sh

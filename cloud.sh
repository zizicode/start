#!/bin/bash
set -e

echo "🔄 Reiniciando túnel de Cloudflare..."

# Detener si hay algún contenedor viejo de cloudflared
sudo docker ps -aq --filter "name=cloudflared" | xargs -r sudo docker rm -f

# Levantar nuevo cloudflared con tu token
sudo docker run -d --name cloudflared \
  --network=tunnel-net \
  cloudflare/cloudflared:latest tunnel run --token ${TUNNEL_TOKEN}

echo "✅ Cloudflared reconectado."

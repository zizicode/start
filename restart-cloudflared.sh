#!/bin/bash
set -e

# Exportar el token
export TUNNEL_TOKEN="eyJhIjoiNzE3M2Y5MWI3MmFjZWFiNTAwYWNmMWY2YmFlYWJmNGIiLCJ0IjoiNzZjN2JhY2MtNjJjOS00Y2JiLWE3NGEtOWQ3OGFmNTg5YmYwIiwicyI6IllqQTVNalF3Tm1JdFlqTmxPQzAwT1RNMkxUaGtNV010TXpaaE5HTTVZVFV5WVdZeSJ9"

# Eliminar contenedor previo si existe
docker rm -f cloudflared || true

# Levantar solo cloudflared con el nuevo token
docker compose -f docker-compose.cloudflared.yml up -d --build

echo "✅ Cloudflared reiniciado y reconectado con el nuevo token"

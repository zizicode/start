#!/usr/bin/env bash
set -euo pipefail

# -------------------------
# CONFIG (reemplaza con tus tokens)
# -------------------------
TS_AUTH_KEY="tskey-auth-kRytAzpsR121CNTRL-ToKgHfW787VHJqEu1TLT7VizEE6K5VdN"
TUNNEL_TOKEN="eyJhIjoiNzE3M2Y5MWI3MmFjZWFiNTAwYWNmMWY2YmFlYWJmNGIiLCJ0IjoiNzZjN2JhY2MtNjJjOS00Y2JiLWE3NGEtOWQ3OGFmNTg5YmYwIiwicyI6IllqQTVNalF3Tm1JdFlqTmxPQzAwT1RNMkxUaGtNV010TXpaaE5HTTVZVFV5WVdZeSJ9"
# -------------------------
echo "=== Actualizando paquetes ==="
sudo apt update -y && sudo apt upgrade -y

echo "=== Instalando OpenSSH y UFW ==="
sudo apt install -y openssh-server ufw
sudo systemctl enable --now ssh
sudo ufw allow ssh || true

echo "=== Instalando Tailscale ==="
curl -fsSL https://tailscale.com/install.sh | sh
sudo tailscale up --authkey="${TS_AUTH_KEY}"

echo "=== Instalando Docker y Docker Compose ==="
if ! command -v docker >/dev/null 2>&1; then
  curl -fsSL https://get.docker.com | sh
  sudo systemctl enable --now docker
fi

if ! command -v docker-compose >/dev/null 2>&1; then
  sudo apt install -y docker-compose
fi

# Exportar token
export TUNNEL_TOKEN="${TUNNEL_TOKEN}"

# Levantar contenedores
chmod +x ./manage.sh
./manage.sh up all

echo "✅ Todo listo! Accede a tus servicios vía Cloudflared."
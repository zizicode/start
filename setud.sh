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

echo "=== Instalando y habilitando OpenSSH ==="
sudo apt install -y openssh-server ufw
sudo systemctl enable --now ssh
sudo ufw allow ssh || true

echo "=== Instalando Tailscale ==="
curl -fsSL https://tailscale.com/install.sh | sh
sudo tailscale up --authkey="${TS_AUTH_KEY}"

echo "=== Instalando Docker ==="
if ! command -v docker >/dev/null 2>&1; then
  curl -fsSL https://get.docker.com | sh
  sudo systemctl enable --now docker
fi

echo "=== Instalando Docker Compose ==="
if ! command -v docker-compose >/dev/null 2>&1; then
  sudo apt install -y docker-compose
fi

echo "🔑 Exportando token de Cloudflared..."
export TUNNEL_TOKEN="${TUNNEL_TOKEN}"

echo "🐳 Construyendo y levantando contenedores..."
docker-compose up -d --build

echo "✅ Todo listo!"
echo "👉 API: https://api.rodolfocordones.com"
echo "📥 Subir archivo: POST https://api.rodolfocordones.com/upload"
echo "📤 Listar archivos: GET https://api.rodolfocordones.com/files"
echo "🖥️ pgAdmin: https://pgadmin.rodolfocordones.com (usuario y contraseña definidos en docker-compose)"

set -euo pipefail

if [ "$EUID" -ne 0 ]; then
  echo "Por favor ejecuta como root (usa sudo)." >&2
  exit 1
fi

if [ $# -ne 1 ]; then
  echo "Uso: $0 <TAILSCALE_AUTHKEY>" >&2
  exit 1
fi

TAILSCALE_KEY="$1"

echo "==> Actualizando paquetes..."
apt-get update -y
apt-get upgrade -y

echo "==> Instalando dependencias para Docker..."
apt-get install -y \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

echo "==> Añadiendo repositorio oficial de Docker..."
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" \
  > /etc/apt/sources.list.d/docker.list

apt-get update -y

echo "==> Instalando Docker Engine y docker compose plugin..."
apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

echo "==> Habilitando y arrancando servicio Docker..."
systemctl enable --now docker

echo "==> Instalando Tailscale..."
curl -fsSL https://tailscale.com/install.sh | sh

echo "==> Iniciando y conectando Tailscale..."
tailscale up --authkey "${TAILSCALE_KEY}"

echo "==> Todo listo."
echo "Comprueba el estado con: tailscale status"

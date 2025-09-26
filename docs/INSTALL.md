# Guía de Instalación Detallada

## Prerequisitos

- Ubuntu Server 20.04+ 
- Acceso root/sudo
- Cuenta de Tailscale
- Auth Key de Tailscale

## Instalación Paso a Paso

### 1. Preparación del Sistema

```bash
sudo apt update && sudo apt upgrade -y
sudo apt install -y curl wget git
```

### 2. Extraer Proyecto

```bash
unzip ubuntu-tailscale-server.zip
cd ubuntu-tailscale-server
```

### 3. Configuración

```bash
cp .env.example .env
nano .env
```

Editar `.env` con tus configuraciones:
- `TS_AUTHKEY`: Tu auth key de Tailscale
- `TS_HOSTNAME`: Nombre para tu servidor
- `API_PORT`: Puerto del API (default: 3001)
- `DATABASE_URL`: URL de tu base de datos

### 4. Añadir tu API

Coloca tu código de `rc-app-api-v1` en el directorio `api/`:

```bash
# Si tienes el repo localmente
cp -r /ruta/a/tu/rc-app-api-v1/* ./api/

# O clonar desde GitHub
git clone https://github.com/tu-usuario/rc-app-api-v1.git api/
```

### 5. Instalación Automática

```bash
chmod +x scripts/*.sh
make install
```

### 6. Configurar Tailscale Funnel

```bash
make configure-funnel
```

## Verificación

```bash
# Ver estado de servicios
make status

# Verificar salud
make health

# Ver logs
make logs
```

## Acceso a Servicios

### Local
- API: http://localhost:3001
- Portainer: http://localhost:9000

### Público (con Funnel)
- API: https://tu-servidor.tu-dominio.ts.net
- Portainer: https://tu-servidor.tu-dominio.ts.net:8443
# Ubuntu Tailscale Server Setup

Configuración completa de servidor Ubuntu con Tailscale, API personalizada y Portainer.

## 🚀 Instalación Rápida

```bash
# 1. Extraer proyecto
unzip ubuntu-tailscale-server.zip
cd ubuntu-tailscale-server

# 2. Copiar tu API
cp -r /ruta/a/tu/rc-app-api-v1/* ./api/
# O clonar: git clone https://github.com/tu-usuario/rc-app-api-v1.git api/

# 3. Configurar variables de entorno
cp .env.example .env
nano .env  # Editar con tus configuraciones

# 4. Instalar todo
make install

# 5. Configurar Tailscale Funnel
make configure-funnel
```

## 📋 Comandos Disponibles

- `make start` - Iniciar servicios
- `make stop` - Detener servicios  
- `make status` - Ver estado
- `make logs` - Ver logs
- `make health` - Verificar salud
- `make update` - Actualizar servicios
- `make backup` - Crear backup

Ver todos los comandos: `make help`

## 🌐 Acceso a Servicios

### Local
- API: http://localhost:3001
- Portainer: http://localhost:9000

### Público (con Funnel)
- API: https://tu-servidor.tu-dominio.ts.net
- Portainer: https://tu-servidor.tu-dominio.ts.net:8443

## 📚 Documentación

- [Instalación detallada](docs/INSTALL.md)
- [Configuración](docs/CONFIG.md)  
- [Troubleshooting](docs/TROUBLESHOOTING.md)

## ⚠️ Requisitos

- Ubuntu Server 20.04+
- Auth Key de Tailscale
- Tu repositorio rc-app-api-v1

## 🆘 Soporte

Para problemas consulta `docs/TROUBLESHOOTING.md` o ejecuta `make health` para diagnóstico.
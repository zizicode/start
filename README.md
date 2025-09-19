# Ubuntu Server Setup & Deployment Script

Este repositorio contiene scripts automatizados para configurar un servidor Ubuntu completo con las siguientes herramientas y servicios:

## 🛠️ Servicios Incluidos

### Infraestructura Base
- **Tailscale**: VPN mesh para conectividad segura
- **OpenSSH**: Servidor SSH para acceso remoto
- **Docker & Docker Compose**: Containerización

### Servicios de Aplicación
- **PostgreSQL**: Base de datos principal
- **pgAdmin**: Interfaz web para gestión de base de datos
- **Portainer**: Gestión visual de contenedores Docker
- **Backend API**: Tu aplicación Node.js desde GitHub
- **Cloudflared**: Túnel seguro con subdominios configurados

## 🚀 Instalación Rápida

### 1. Clonar el repositorio

\`\`\`bash
git clone <tu-repositorio-url>
cd ubuntu-server-setup
\`\`\`

### 2. Configurar variables de entorno

\`\`\`bash
cp .env.example .env
nano .env
\`\`\`

Completa **todas** las variables requeridas:

#### Configuración Base
- `TAILSCALE_AUTH_KEY`: Obtén tu clave desde [Tailscale Admin Console](https://login.tailscale.com/admin/settings/keys)
- `CLOUDFLARED_TOKEN`: Obtén tu token desde [Cloudflare Zero Trust Dashboard](https://dash.cloudflare.com/)
- `TUNNEL_ID`: ID del túnel de Cloudflare

#### Configuración de Base de Datos
- `POSTGRES_DB`: Nombre de la base de datos
- `POSTGRES_USER`: Usuario de PostgreSQL
- `POSTGRES_PASSWORD`: Contraseña segura para PostgreSQL
- `PGLADMIN_EMAIL`: Email para acceso a pgAdmin
- `PGLADMIN_PASSWORD`: Contraseña para pgAdmin

#### Configuración del Backend
- `GITHUB_REPO_URL`: URL de tu repositorio rc_backend_api
- `JWT_SECRET`: Clave secreta para JWT (mínimo 32 caracteres)
- `API_KEY`: Clave API para tu backend

### 3. Ejecutar instalación completa

\`\`\`bash
# Instalación inicial del sistema
chmod +x init.sh
./init.sh

# Despliegue completo de servicios
chmod +x quick-deploy.sh
./quick-deploy.sh
\`\`\`

## 🌐 Acceso a Servicios

### URLs Públicas (vía Cloudflare Tunnel)
- **API Backend**: https://api.rodolfocordones.com
- **Portainer**: https://docker.rodolfocordones.com  
- **pgAdmin**: https://pgladmin.rodolfocordones.com

### URLs Locales (para desarrollo/testing)
- **Portainer**: http://localhost:9000
- **pgAdmin**: http://localhost:5050
- **API Backend**: http://localhost:4000
- **PostgreSQL**: localhost:5432

## 📋 Requisitos Previos

- Ubuntu Server 20.04 LTS o superior
- Usuario con privilegios sudo (no ejecutar como root)
- Conexión a internet estable
- Cuentas activas en:
  - [Tailscale](https://tailscale.com/)
  - [Cloudflare](https://cloudflare.com/) con Zero Trust configurado
  - [GitHub](https://github.com/) con repositorio rc_backend_api

## 🔧 Scripts Disponibles

### Scripts Principales
- `init.sh`: Configuración inicial del sistema (Tailscale, SSH, Docker)
- `deploy.sh`: Despliegue de todos los servicios
- `quick-deploy.sh`: Ejecuta todo el proceso automáticamente

### Scripts de Utilidad
- `scripts/create-secrets.sh`: Crea archivos de secretos necesarios
- `scripts/check-deployment.sh`: Verifica estado de todos los servicios
- `scripts/check-services.sh`: Verifica servicios base del sistema

## 📁 Estructura del Proyecto

\`\`\`
start/
├── init.sh                      # Script inicial del sistema
├── deploy.sh                    # Script principal de despliegue
├── quick-deploy.sh              # Script de despliegue rápido
├── docker-compose.yml           # Cloudflared básico
├── docker-compose.db.yml        # PostgreSQL + pgAdmin
├── docker-compose.management.yml # Portainer
├── docker-compose.api.yml       # Backend API
├── docker-compose.tunnel.yml    # Cloudflared completo
├── cloudflared/
│   └── config.yml              # Configuración de rutas del túnel
├── pgladmin/
│   └── servers.json            # Configuración de servidores pgAdmin
├── init-scripts/
│   └── 01-init-database.sql    # Script inicial de base de datos
├── scripts/
│   ├── create-secrets.sh       # Creación de secretos
│   ├── check-deployment.sh     # Verificación de despliegue
│   └── check-services.sh       # Verificación de servicios
├── .env.example                # Plantilla de variables
└── README.md                   # Esta documentación
\`\`\`

## 🔄 Proceso de Despliegue

El script `deploy.sh` ejecuta los siguientes pasos automáticamente:

1. **Gestión del Repositorio**: Clona/actualiza rc_backend_api desde GitHub
2. **Build de Imagen**: Construye la imagen Docker del backend
3. **Base de Datos**: Despliega PostgreSQL y pgAdmin
4. **Gestión**: Despliega Portainer para administración
5. **API**: Despliega el backend con conexión a base de datos
6. **Túnel**: Configura Cloudflared con todas las rutas
7. **Verificación**: Comprueba que todos los servicios estén funcionando

## 🔍 Verificación y Monitoreo

### Verificación Automática
\`\`\`bash
./scripts/check-deployment.sh
\`\`\`

### Verificación Manual
\`\`\`bash
# Estado de contenedores
docker ps

# Logs de servicios
docker logs postgres
docker logs pgladmin
docker logs portainer
docker logs api
docker logs cloudflared-tunnel

# Estado de redes
docker network ls

# Salud de la API
curl http://localhost:4000/health
\`\`\`

## 🚨 Solución de Problemas

### Problemas de Base de Datos
\`\`\`bash
# Verificar PostgreSQL
docker exec postgres pg_isready -U postgres

# Reiniciar servicios de BD
docker-compose -f docker-compose.db.yml restart
\`\`\`

### Problemas del Backend
\`\`\`bash
# Verificar logs del API
docker logs api

# Reconstruir imagen
cd rc_backend_api
docker build -t rc-backend-api:latest .
docker-compose -f ../docker-compose.api.yml up -d
\`\`\`

### Problemas de Cloudflared
\`\`\`bash
# Verificar configuración del túnel
cat cloudflared/config.yml

# Reiniciar túnel
docker-compose -f docker-compose.tunnel.yml restart

# Logs detallados
docker logs cloudflared-tunnel
\`\`\`

### Problemas de Red
\`\`\`bash
# Recrear redes Docker
docker network rm tunnel-net db-net
docker network create tunnel-net
docker network create db-net
\`\`\`

## 🔒 Configuración de Seguridad

### Credenciales por Defecto
- **Portainer**: admin / admin123 (cambiar después del primer acceso)
- **PostgreSQL**: postgres / [tu_password_del_.env]
- **pgAdmin**: [tu_email_del_.env] / [tu_password_del_.env]

### Recomendaciones de Seguridad
1. Cambiar todas las contraseñas por defecto
2. Configurar certificados SSL personalizados si es necesario
3. Revisar configuraciones de firewall
4. Monitorear logs regularmente
5. Mantener actualizadas las imágenes Docker

## 📝 Notas Importantes

1. **Orden de Despliegue**: Los servicios se despliegan en orden específico para resolver dependencias
2. **Persistencia**: Todos los datos se almacenan en volúmenes Docker persistentes
3. **Redes**: Se utilizan redes Docker separadas para seguridad (tunnel-net, db-net)
4. **Health Checks**: Los servicios incluyen verificaciones de salud automáticas
5. **Logs**: Configuración de rotación de logs para evitar llenar el disco

## 🛠️ Servicios Instalados

### Tailscale
- **Puerto**: N/A (VPN mesh)
- **Estado**: `tailscale status`
- **Logs**: `sudo journalctl -u tailscaled`

### OpenSSH
- **Puerto**: 22
- **Estado**: `sudo systemctl status ssh`
- **Configuración**: `/etc/ssh/sshd_config`

### Docker
- **Socket**: `/var/run/docker.sock`
- **Estado**: `sudo systemctl status docker`
- **Contenedores**: `docker ps`

### Cloudflared
- **Contenedor**: `cloudflared-tunnel`
- **Red**: `tunnel-net`
- **Logs**: `docker logs cloudflared-tunnel`

### PostgreSQL
- **Puerto**: 5432
- **Estado**: `docker exec postgres pg_isready -U postgres`
- **Logs**: `docker logs postgres`

### pgAdmin
- **Puerto**: 5050
- **Estado**: `docker exec pgladmin pgAdmin4`
- **Logs**: `docker logs pgladmin`

### Portainer
- **Puerto**: 9000
- **Estado**: `docker exec portainer portainer`
- **Logs**: `docker logs portainer`

### Backend API
- **Puerto**: 4000
- **Estado**: `docker exec api node --version`
- **Logs**: `docker logs api`

## 🔍 Verificación Post-Instalación

\`\`\`bash
# Verificar Tailscale
tailscale status

# Verificar SSH
sudo systemctl status ssh
ss -tlnp | grep :22

# Verificar Docker
docker --version
docker-compose --version
docker network ls | grep tunnel-net

# Verificar Cloudflared
docker ps | grep cloudflared
docker logs cloudflared-tunnel

# Verificar PostgreSQL
docker exec postgres pg_isready -U postgres

# Verificar pgAdmin
docker exec pgladmin pgAdmin4

# Verificar Portainer
docker exec portainer portainer

# Verificar Backend API
docker exec api node --version
curl http://localhost:4000/health
\`\`\`

## 🚨 Solución de Problemas

### Tailscale no se conecta
\`\`\`bash
sudo tailscale down
sudo tailscale up --authkey="$TAILSCALE_AUTH_KEY" --accept-routes --reset
\`\`\`

### SSH no funciona
\`\`\`bash
sudo systemctl restart ssh
sudo ufw status
sudo ufw allow 22/tcp
\`\`\`

### Docker requiere sudo
\`\`\`bash
# Cerrar sesión y volver a iniciar para aplicar cambios de grupo
exit
# O reiniciar el sistema
sudo reboot
\`\`\`

### Cloudflared no inicia
\`\`\`bash
# Verificar token
echo $CLOUDFLARED_TOKEN

# Recrear contenedor
docker-compose down
docker-compose up -d

# Ver logs detallados
docker-compose logs cloudflared
\`\`\`

### PostgreSQL no está disponible
\`\`\`bash
# Verificar PostgreSQL
docker exec postgres pg_isready -U postgres

# Reiniciar servicios de BD
docker-compose -f docker-compose.db.yml restart
\`\`\`

### pgAdmin no funciona
\`\`\`bash
# Verificar logs de pgAdmin
docker logs pgladmin

# Reiniciar pgAdmin
docker-compose -f docker-compose.db.yml restart pgladmin
\`\`\`

### Portainer no está disponible
\`\`\`bash
# Verificar logs de Portainer
docker logs portainer

# Reiniciar Portainer
docker-compose -f docker-compose.management.yml restart portainer
\`\`\`

### Backend API no está funcionando
\`\`\`bash
# Verificar logs del API
docker logs api

# Reconstruir imagen
cd rc_backend_api
docker build -t rc-backend-api:latest .
docker-compose -f ../docker-compose.api.yml up -d
\`\`\`

## 🤝 Contribuciones

Si encuentras algún problema o tienes sugerencias de mejora, por favor:

1. Abre un issue describiendo el problema
2. Propón una solución mediante pull request
3. Documenta cualquier cambio en el README

## 📄 Licencia

Este proyecto está bajo la Licencia MIT. Ver el archivo LICENSE para más detalles.

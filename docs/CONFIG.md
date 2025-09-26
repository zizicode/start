# Configuración

## Variables de Entorno

### Tailscale
- `TS_AUTHKEY`: Auth key de Tailscale
- `TS_HOSTNAME`: Hostname del servidor

### API  
- `API_PORT`: Puerto del API (default: 3001)
- `NODE_ENV`: Entorno de Node.js
- `DATABASE_URL`: URL de base de datos

### Portainer
- `PORTAINER_PORT`: Puerto de Portainer (default: 9000)

## Configuración de Tailscale

### Serve Configuration
Tailscale Serve mapea servicios locales:
- Puerto 443 → API (3001)
- Puerto 8443 → Portainer (9000)

### Funnel Configuration  
Tailscale Funnel expone servicios públicamente.

### Comandos útiles
```bash
# Ver estado
sudo tailscale status

# Configurar Serve
sudo tailscale serve https:443 http://localhost:3001

# Activar Funnel
sudo tailscale funnel 443 on

# Ver configuración
sudo tailscale serve status
sudo tailscale funnel status
```

## Docker Compose

El archivo `docker-compose.yml` incluye:
- `tailscale`: Cliente Tailscale
- `api`: Tu API personalizada  
- `portainer`: Gestión de contenedores
- `nginx-proxy`: Proxy reverso

## Nginx

Configuración en `nginx/nginx.conf`:
- Proxy reverso para API
- Headers de seguridad
- Rate limiting
- Compression

## Firewall

UFW configurado para permitir:
- SSH (22)
- API (3001) 
- Portainer (9000, 9443)
- HTTP/HTTPS (80, 443)
- Tailscale (tailscale0 interface)
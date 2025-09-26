# Troubleshooting

## Problemas Comunes

### Tailscale no se conecta

```bash
# Verificar servicio
sudo systemctl status tailscaled

# Reiniciar servicio  
sudo systemctl restart tailscaled

# Reconectar con nuevo auth key
sudo tailscale up --reset
sudo tailscale up --authkey=nuevo_auth_key
```

### API no responde

```bash
# Ver logs del contenedor
docker-compose logs api

# Verificar que el puerto esté libre
sudo netstat -tulpn | grep :3001

# Reiniciar servicio
docker-compose restart api
```

### Portainer no accesible

```bash
# Verificar contenedor
docker-compose ps portainer

# Ver logs
docker-compose logs portainer

# Verificar permisos de Docker socket
ls -la /var/run/docker.sock
```

### Funnel no funciona

```bash
# Verificar que Funnel esté habilitado en tailnet
# Ir a admin.tailscale.com → Settings → Features

# Verificar configuración
sudo tailscale funnel status

# Reconfigurar
sudo tailscale serve reset
sudo tailscale serve https:443 http://localhost:3001
sudo tailscale funnel 443 on
```

### Docker no inicia servicios

```bash
# Verificar Docker
sudo systemctl status docker

# Verificar compose file
docker-compose config

# Ver logs detallados
docker-compose up --no-daemon
```

### Problemas de red

```bash
# Verificar firewall
sudo ufw status verbose

# Verificar iptables
sudo iptables -L

# Verificar conectividad Tailscale  
ping <otra-maquina-tailscale>
```

## Logs Importantes

### Ubicaciones de logs
- Docker: `docker-compose logs`
- Nginx: `nginx/logs/`
- API: `api/logs/`
- Tailscale: `journalctl -u tailscaled`
- Sistema: `journalctl -xe`

### Comandos de diagnóstico
```bash
# Estado completo del sistema
make health

# Logs en tiempo real
make logs

# Estado de Tailscale
make tailscale-status

# Puertos en uso
sudo netstat -tulpn
```

## Recuperación

### Reinicio completo
```bash
make stop
make clean
make start
```

### Restaurar backup
```bash
tar -xzf backup-file.tar.gz
make start
```

### Reset Tailscale
```bash
sudo tailscale logout
sudo tailscale up --authkey=nuevo_auth_key
sudo ./scripts/configure-funnel.sh
```
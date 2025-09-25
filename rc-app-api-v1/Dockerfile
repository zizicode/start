FROM node:18-alpine

# Instalar curl para health checks
RUN apk add --no-cache curl

# Crear directorio de la aplicación
WORKDIR /app

# Copiar package.json y package-lock.json
COPY package*.json ./

# Instalar dependencias
RUN npm ci --only=production

# Copiar código fuente
COPY . .

# Crear usuario no-root para seguridad
RUN addgroup -g 1001 -S nodejs
RUN adduser -S nodejs -u 1001

# Crear directorio para datos y logs
RUN mkdir -p /app/data /app/logs
RUN chown -R nodejs:nodejs /app

# Cambiar a usuario no-root
USER nodejs

# Exponer el puerto
EXPOSE 3030

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:3030/health || exit 1


# Comando para ejecutar (usa la carpeta compilada dist/)
CMD ["node", "dist/server.js"]

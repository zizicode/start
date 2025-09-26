FROM node:18-alpine

WORKDIR /app
RUN apk add --no-cache curl

# Copia solo los archivos necesarios para instalar deps
COPY package*.json tsconfig.json ./

# Instala dependencias de desarrollo para poder compilar
RUN npm install

# Copia el resto del código
COPY . .

# Compila TypeScript a dist/
RUN npm run build

# Ahora elimina devDependencies para dejar solo prod (opcional)
RUN npm prune --production && npm cache clean --force

# Crear directorios necesarios
RUN mkdir -p logs uploads \
    && addgroup -g 1001 -S nodejs \
    && adduser -S nodejs -u 1001 \
    && chown -R nodejs:nodejs /app

USER nodejs
EXPOSE 3001

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:3001/health || exit 1

CMD ["npm", "start"]

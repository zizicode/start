# Imagen base
FROM node:20

# Crear directorio de trabajo
WORKDIR /usr/src/app

# Copiar package.json y package-lock.json primero (mejor cache)
COPY package*.json ./

# Instalar dependencias
RUN npm install

# Copiar el resto del código
COPY . .

# Compilar TypeScript a JavaScript
RUN npm run build

# Exponer el puerto
EXPOSE 3030

# Comando para ejecutar (usa la carpeta compilada dist/)
CMD ["node", "dist/server.js"]

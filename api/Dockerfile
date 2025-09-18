# Etapa de build
FROM node:18-alpine AS builder

WORKDIR /usr/src/app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

# Etapa final
FROM node:18-alpine

WORKDIR /usr/src/app
COPY package*.json ./
RUN npm ci --omit=dev
COPY --from=builder /usr/src/app/dist ./dist

# Instalar cliente postgres para usar pg_isready
RUN apk add --no-cache postgresql-client

EXPOSE 4000

CMD ["sh", "-c", "until pg_isready -h $DB_HOST -p $DB_PORT -U $DB_USER; do echo 'Esperando Postgres...'; sleep 2; done && node dist/server.js"]

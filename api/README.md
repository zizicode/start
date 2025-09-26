# API Directory

Coloca aquí tu código de rc-app-api-v1

## Opciones:

### 1. Copiar archivos manualmente
```bash
cp -r /ruta/a/tu/rc-app-api-v1/* ./api/
```

### 2. Clonar desde repositorio
```bash
# Desde el directorio raíz del proyecto
git clone https://github.com/tu-usuario/rc-app-api-v1.git api/
```

### 3. Mover repositorio existente
```bash
mv /ruta/a/tu/rc-app-api-v1/* ./api/
```

## Requisitos para tu API

Tu API debe tener:
- `package.json` con script `start`
- Endpoint `/health` para health checks
- Puerto configurable via variable `PORT`

## Estructura esperada:
```
api/
├── package.json
├── src/
│   └── ... (tu código)
├── logs/ (se creará automáticamente)
└── uploads/ (se creará automáticamente)
```

Después de colocar tu código:
1. `cd ../` (volver al directorio raíz)
2. `make start` (iniciar servicios)
3. `make health` (verificar estado)
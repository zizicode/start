# Blog API REST

API REST completa para un blog con autenticación JWT, CRUD de posts, usuarios y multimedia.

## 🚀 Características

- ✅ Autenticación JWT con roles (admin, editor, author)
- ✅ CRUD completo para usuarios, posts y media
- ✅ Subida de imágenes y videos con Multer
- ✅ Archivos multimedia públicos (sin autenticación)
- ✅ Rutas CRUD protegidas con token
- ✅ Conexión a PostgreSQL
- ✅ Estructura modular (controllers, models, routes, middleware)
- ✅ Validación de archivos (imágenes y videos)
- ✅ Logging con Morgan

## 📦 Instalación

1. Instalar dependencias:
\`\`\`bash
npm install
\`\`\`

2. Configurar variables de entorno en `.env`:
\`\`\`env
DB_HOST=localhost
DB_PORT=5432
DB_USER=postgres
DB_PASSWORD=tu_password
DB_NAME=blog_db
PORT=3000
JWT_SECRET=tu_secreto_super_seguro
JWT_EXPIRES_IN=7d
\`\`\`

3. Crear la base de datos y ejecutar el script SQL:
\`\`\`bash
psql -U postgres -d blog_db -f scripts/init-database.sql
\`\`\`

4. Iniciar el servidor:
\`\`\`bash
npm run dev
\`\`\`

## 📚 Endpoints

### Autenticación (sin token)
- `POST /api/auth/register` - Registrar usuario
- `POST /api/auth/login` - Iniciar sesión
- `GET /api/auth/profile` - Ver perfil (requiere token)

### Posts
- `GET /api/posts` - Listar posts (público)
- `GET /api/posts/:id` - Ver post por ID (público)
- `GET /api/posts/slug/:slug` - Ver post por slug (público)
- `POST /api/posts` - Crear post (requiere token)
- `PUT /api/posts/:id` - Actualizar post (requiere token)
- `DELETE /api/posts/:id` - Eliminar post (requiere token)

### Media
- `GET /api/media` - Listar archivos (público)
- `GET /api/media/:id` - Ver archivo por ID (público)
- `POST /api/media` - Subir archivo (requiere token)
- `PUT /api/media/:id` - Actualizar metadata (requiere token)
- `DELETE /api/media/:id` - Eliminar archivo (requiere token)

### Usuarios (solo admin)
- `GET /api/users` - Listar usuarios (requiere token admin)
- `GET /api/users/:id` - Ver usuario (requiere token admin)
- `PUT /api/users/:id` - Actualizar usuario (requiere token admin)
- `DELETE /api/users/:id` - Eliminar usuario (requiere token admin)

### Archivos estáticos
- `GET /media/:filename` - Acceso público a imágenes y videos

## 🔐 Autenticación

Incluir el token en el header:
\`\`\`
Authorization: Bearer tu_token_jwt
\`\`\`

## 📝 Ejemplo de uso

### 1. Registrar usuario
\`\`\`bash
curl -X POST http://localhost:3000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{"email":"user@example.com","password":"password123","role":"author"}'
\`\`\`

### 2. Login
\`\`\`bash
curl -X POST http://localhost:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"user@example.com","password":"password123"}'
\`\`\`

### 3. Crear post
\`\`\`bash
curl -X POST http://localhost:3000/api/posts \
  -H "Authorization: Bearer TU_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"title":"Mi primer post","slug":"mi-primer-post","body":"<p>Contenido HTML</p>","published":true}'
\`\`\`

### 4. Subir imagen
\`\`\`bash
curl -X POST http://localhost:3000/api/media \
  -H "Authorization: Bearer TU_TOKEN" \
  -F "file=@imagen.jpg" \
  -F "title=Mi imagen" \
  -F "description=Descripción de la imagen"
\`\`\`

## 🛠️ Tecnologías

- Node.js + Express
- PostgreSQL
- JWT (jsonwebtoken)
- Bcrypt
- Multer
- Morgan
- CORS
- dotenv

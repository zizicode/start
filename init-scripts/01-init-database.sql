-- ============================================================
-- Script inicial de base de datos
-- Este script se ejecuta automáticamente al iniciar el contenedor de PostgreSQL
-- ============================================================

-- Extensiones necesarias
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";   -- Para generar UUIDs
CREATE EXTENSION IF NOT EXISTS "pgcrypto";    -- Para encriptación/funciones hash

-- ============================================================
-- Tabla de usuarios
-- ============================================================
CREATE TABLE IF NOT EXISTS users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),  -- Identificador único del usuario
    email VARCHAR(255) UNIQUE NOT NULL,              -- Correo electrónico (único)
    password_hash VARCHAR(255) NOT NULL,             -- Hash de la contraseña
    name VARCHAR(255),                               -- Nombre completo del usuario
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(), -- Fecha de creación
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()  -- Última actualización
);

-- Índices para mejorar consultas en usuarios
CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
CREATE INDEX IF NOT EXISTS idx_users_created_at ON users(created_at);

-- ============================================================
-- Tabla de archivos multimedia
-- ============================================================
CREATE TABLE IF NOT EXISTS media_files (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),    -- Identificador único del archivo
    file_name VARCHAR(255) NOT NULL,                   -- Nombre original del archivo
    file_path TEXT NOT NULL,                           -- Ruta donde se almacena el archivo
    file_type VARCHAR(50) NOT NULL CHECK (file_type IN ('image', 'video')), -- Tipo de archivo
    mime_type VARCHAR(100) NOT NULL,                   -- MIME type (ej. image/png, video/mp4)
    file_size BIGINT CHECK (file_size >= 0),           -- Tamaño en bytes
    duration_seconds INT CHECK (duration_seconds >= 0),-- Duración (solo si es video, NULL si es imagen)
    resolution VARCHAR(50),                            -- Resolución (ej. 1920x1080) opcional
    registered_by UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE, -- Usuario que lo registró
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(), -- Fecha de creación
    last_update TIMESTAMP WITH TIME ZONE DEFAULT NOW() -- Última modificación
);

-- Índices para acelerar consultas en archivos multimedia
CREATE INDEX IF NOT EXISTS idx_media_type ON media_files(file_type);
CREATE INDEX IF NOT EXISTS idx_media_registered_by ON media_files(registered_by);
CREATE INDEX IF NOT EXISTS idx_media_created_at ON media_files(created_at);

-- ============================================================
-- Ejemplo de inserción (opcional)
-- ============================================================
-- INSERT INTO media_files (file_name, file_path, file_type, mime_type, file_size, registered_by)
-- VALUES ('foto.png', '/uploads/foto.png', 'image', 'image/png', 204800, 'UUID_USUARIO');


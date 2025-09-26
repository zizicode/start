-- =====================================
-- Base de datos para gestión de posts y multimedia
-- =====================================

-- Tabla de usuarios
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(100) NOT NULL,
    username VARCHAR(50) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    email VARCHAR(100) UNIQUE,
    role VARCHAR(20) DEFAULT 'admin',
    last_login TIMESTAMP,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Tabla de posts
CREATE TABLE posts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title VARCHAR(255) NOT NULL,
    slug VARCHAR(255) UNIQUE NOT NULL,
    body TEXT NOT NULL, -- HTML del post
    description VARCHAR(255), -- descripción para SEO
    cover_image VARCHAR(255), -- ruta de imagen de portada
    keywords VARCHAR(255), -- palabras clave, separadas por coma
    created_by UUID REFERENCES users(id),
    status VARCHAR(20) DEFAULT 'draft', -- draft, published
    views INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Tabla de multimedia
CREATE TABLE media (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    original_name VARCHAR(255) NOT NULL,
    stored_name VARCHAR(255) NOT NULL,
    type VARCHAR(50) NOT NULL, -- 'image' o 'video'
    size BIGINT NOT NULL, -- tamaño en bytes
    width INT,
    height INT,
    url VARCHAR(500) NOT NULL, -- enlace completo
    uploaded_by UUID REFERENCES users(id),
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Index para búsqueda por slug en posts
CREATE INDEX idx_posts_slug ON posts(slug);

-- Index para búsqueda por username en users
CREATE INDEX idx_users_username ON users(username);

-- Index por tipo en media
CREATE INDEX idx_media_type ON media(type);

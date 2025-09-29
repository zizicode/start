-- Script para inicializar la base de datos del blog

-- Tabla de usuarios
CREATE TABLE IF NOT EXISTS public.users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  email TEXT UNIQUE NOT NULL,
  password_hash TEXT NOT NULL,
  role TEXT CHECK (role IN ('admin','editor','author')) DEFAULT 'author',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ
);

-- Tabla de publicaciones
CREATE TABLE IF NOT EXISTS public.posts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title TEXT NOT NULL,
  slug TEXT UNIQUE NOT NULL,
  body TEXT NOT NULL,
  cover_url TEXT,
  author_id UUID REFERENCES public.users(id) ON DELETE SET NULL,
  views INTEGER NOT NULL DEFAULT 0,
  published BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ
);

-- Tabla de multimedia (fotos y videos)
CREATE TABLE IF NOT EXISTS public.media (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  file_url TEXT NOT NULL,
  type TEXT CHECK (type IN ('image','video')) NOT NULL,
  title TEXT,
  description TEXT,
  uploaded_by UUID REFERENCES public.users(id) ON DELETE SET NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Índices para mejorar el rendimiento
CREATE INDEX IF NOT EXISTS idx_posts_slug ON public.posts(slug);
CREATE INDEX IF NOT EXISTS idx_posts_author ON public.posts(author_id);
CREATE INDEX IF NOT EXISTS idx_posts_published ON public.posts(published);
CREATE INDEX IF NOT EXISTS idx_media_type ON public.media(type);
CREATE INDEX IF NOT EXISTS idx_media_uploaded_by ON public.media(uploaded_by);

-- Insertar usuario admin por defecto (password: admin123)
INSERT INTO public.users (email, password_hash, role) 
VALUES ('admin@blog.com', '$2b$10$rKvVJZXqQxGxGxGxGxGxGOXqQxGxGxGxGxGxGxGxGxGxGxGxGxGxG', 'admin')
ON CONFLICT (email) DO NOTHING;

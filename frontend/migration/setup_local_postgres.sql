-- Script para crear base de datos compatible con tu schema actual
-- Ejecutar en PostgreSQL local/remoto

-- Crear base de datos
CREATE DATABASE biblioteca_digital;
\c biblioteca_digital;

-- Crear extensiones necesarias
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- Crear secuencia para requests
CREATE SEQUENCE requests_id_seq;

-- Tabla de usuarios (reemplaza auth.users de Supabase)
CREATE TABLE public.users (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  email text NOT NULL UNIQUE,
  name text NOT NULL,
  role text DEFAULT 'user'::text,
  password_hash text, -- Compatible con migración de usuarios desde Supabase
  created_at timestamp without time zone DEFAULT now(),
  CONSTRAINT users_pkey PRIMARY KEY (id)
);

-- Tabla de libros
CREATE TABLE public.books (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  title text NOT NULL,
  author text NOT NULL,
  description text,
  cover_url text,
  file_url text NOT NULL,
  format text CHECK (format = ANY (ARRAY['pdf'::text, 'epub'::text])),
  categories text[], -- Cambiado de ARRAY a text[]
  published_date date,
  created_at timestamp without time zone DEFAULT now(),
  created_by uuid,
  category text DEFAULT 'General'::text,
  isbn text,
  year integer,
  subcategory text,
  CONSTRAINT books_pkey PRIMARY KEY (id),
  CONSTRAINT fk_books_created_by FOREIGN KEY (created_by) REFERENCES public.users(id)
);

-- Tabla de videos
CREATE TABLE public.videos (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  title text NOT NULL,
  description text,
  thumbnail_url text,
  video_id text NOT NULL,
  category text NOT NULL,
  duration integer,
  views integer DEFAULT 0,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  subcategory text,
  created_by uuid,
  CONSTRAINT videos_pkey PRIMARY KEY (id),
  CONSTRAINT videos_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id)
);

-- Tabla de favoritos
CREATE TABLE public.favorites (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  user_id uuid,
  book_id uuid,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT favorites_pkey PRIMARY KEY (id),
  CONSTRAINT favorites_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id),
  CONSTRAINT favorites_book_id_fkey FOREIGN KEY (book_id) REFERENCES public.books(id)
);

-- Tabla de historial de lectura
CREATE TABLE public.reading_history (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  user_id uuid,
  book_id uuid,
  last_read timestamp with time zone DEFAULT now(),
  progress integer DEFAULT 0,
  CONSTRAINT reading_history_pkey PRIMARY KEY (id),
  CONSTRAINT reading_history_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id),
  CONSTRAINT reading_history_book_id_fkey FOREIGN KEY (book_id) REFERENCES public.books(id)
);

-- Tabla de estadísticas de libros
CREATE TABLE public.book_stats (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  book_id uuid NOT NULL UNIQUE,
  open_count integer NOT NULL DEFAULT 0,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT book_stats_pkey PRIMARY KEY (id),
  CONSTRAINT book_stats_book_id_fkey FOREIGN KEY (book_id) REFERENCES public.books(id)
);

-- Tabla de historial de aperturas de libros
CREATE TABLE public.book_opens_history (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  book_id uuid NOT NULL,
  user_id uuid NOT NULL,
  opened_at timestamp with time zone DEFAULT now(),
  CONSTRAINT book_opens_history_pkey PRIMARY KEY (id),
  CONSTRAINT book_opens_history_book_id_fkey FOREIGN KEY (book_id) REFERENCES public.books(id),
  CONSTRAINT book_opens_history_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id)
);

-- Tabla de solicitudes
CREATE TABLE public.requests (
  id integer NOT NULL DEFAULT nextval('requests_id_seq'::regclass),
  user_id uuid,
  user_name text,
  user_email text,
  admin_email text,
  request_text text,
  status text DEFAULT 'pendiente'::text,
  created_at timestamp without time zone DEFAULT now(),
  CONSTRAINT requests_pkey PRIMARY KEY (id),
  CONSTRAINT requests_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id)
);

-- Índices para mejor rendimiento
CREATE INDEX idx_books_category ON public.books(category);
CREATE INDEX idx_books_title ON public.books(title);
CREATE INDEX idx_videos_category ON public.videos(category);
CREATE INDEX idx_users_email ON public.users(email);
CREATE INDEX idx_favorites_user_book ON public.favorites(user_id, book_id);
CREATE INDEX idx_reading_history_user ON public.reading_history(user_id);

-- Función para actualizar updated_at automáticamente
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Triggers para updated_at
CREATE TRIGGER update_videos_updated_at BEFORE UPDATE ON public.videos
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_book_stats_updated_at BEFORE UPDATE ON public.book_stats
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Insertar usuarios de prueba (contraseñas hasheadas con bcrypt)
INSERT INTO public.users (email, name, role, password_hash) VALUES
('admin@biblioteca.com', 'Administrador', 'admin', '$2b$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi'), -- password: password
('bibliotecario@biblioteca.com', 'Bibliotecario', 'bibliotecario', '$2b$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi'),
('lector@biblioteca.com', 'Lector', 'user', '$2b$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi');

-- Mensaje de confirmación
SELECT 'Base de datos biblioteca_digital creada exitosamente' as status;
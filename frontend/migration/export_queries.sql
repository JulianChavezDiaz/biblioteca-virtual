-- 📋 QUERIES CORREGIDAS PARA EXPORTAR DESDE CUENTA ACTUAL
-- Ejecutar en SQL Editor de tu cuenta ACTUAL de Supabase

-- 1. EXPORTAR USUARIOS
SELECT 
  'INSERT INTO users (id, email, name, role, created_at) VALUES (''' ||
  id || ''', ''' || 
  email || ''', ''' || 
  name || ''', ''' || 
  role || ''', ''' || 
  created_at || ''');' as insert_statement
FROM users;

-- 2. EXPORTAR LIBROS  
SELECT 
  'INSERT INTO books (id, title, author, description, cover_url, file_url, format, category, isbn, year, subcategory, created_at, created_by) VALUES (''' ||
  id || ''', ''' || 
  REPLACE(title, '''', '''''') || ''', ''' || 
  REPLACE(author, '''', '''''') || ''', ''' || 
  COALESCE(REPLACE(description, '''', ''''''), '') || ''', ''' || 
  COALESCE(cover_url, '') || ''', ''' || 
  file_url || ''', ''' || 
  COALESCE(format, 'pdf') || ''', ''' || 
  COALESCE(category, 'General') || ''', ''' || 
  COALESCE(isbn, '') || ''', ' || 
  COALESCE(year::text, 'NULL') || ', ''' || 
  COALESCE(subcategory, '') || ''', ''' || 
  created_at || ''', ''' || 
  COALESCE(created_by::text, 'NULL') || ''');' as insert_statement
FROM books;

-- 3. EXPORTAR VIDEOS
SELECT 
  'INSERT INTO videos (id, title, description, thumbnail_url, video_id, category, duration, views, created_at, updated_at, subcategory, created_by) VALUES (''' ||
  id || ''', ''' || 
  REPLACE(title, '''', '''''') || ''', ''' || 
  COALESCE(REPLACE(description, '''', ''''''), '') || ''', ''' || 
  COALESCE(thumbnail_url, '') || ''', ''' || 
  video_id || ''', ''' || 
  category || ''', ' || 
  COALESCE(duration::text, 'NULL') || ', ' || 
  views || ', ''' || 
  created_at || ''', ''' || 
  updated_at || ''', ''' || 
  COALESCE(subcategory, '') || ''', ''' || 
  COALESCE(created_by::text, 'NULL') || ''');' as insert_statement
FROM videos;

-- 4. EXPORTAR FAVORITOS (si tienes)
SELECT 
  'INSERT INTO favorites (id, user_id, book_id, created_at) VALUES (''' ||
  id || ''', ''' || 
  user_id || ''', ''' || 
  book_id || ''', ''' || 
  created_at || ''');' as insert_statement
FROM favorites;

-- 5. EXPORTAR HISTORIAL DE LECTURA (si tienes)
SELECT 
  'INSERT INTO reading_history (id, user_id, book_id, last_read, progress) VALUES (''' ||
  id || ''', ''' || 
  user_id || ''', ''' || 
  book_id || ''', ''' || 
  last_read || ''', ' || 
  progress || ');' as insert_statement
FROM reading_history;
-- Script para crear buckets de storage en Supabase
-- Ejecutar en SQL Editor de Supabase

-- 1. Crear bucket para libros (PDFs, EPUBs)
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'books',
  'books', 
  true,
  52428800, -- 50MB limit
  ARRAY['application/pdf', 'application/epub+zip']
);

-- 2. Crear bucket para portadas de libros
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'covers',
  'covers',
  true, 
  5242880, -- 5MB limit
  ARRAY['image/jpeg', 'image/png', 'image/webp', 'image/jpg']
);

-- 3. Políticas para bucket 'books'
-- Permitir lectura pública
CREATE POLICY "Public Access" ON storage.objects FOR SELECT USING (bucket_id = 'books');

-- Permitir subida a usuarios autenticados con roles específicos
CREATE POLICY "Allow upload for admins and teachers" ON storage.objects 
FOR INSERT WITH CHECK (
  bucket_id = 'books' 
  AND auth.role() = 'authenticated'
  AND EXISTS (
    SELECT 1 FROM public.users 
    WHERE users.id = auth.uid() 
    AND users.role IN ('admin', 'profesor', 'bibliotecario')
  )
);

-- Permitir actualización a usuarios autenticados con roles específicos
CREATE POLICY "Allow update for admins and teachers" ON storage.objects 
FOR UPDATE USING (
  bucket_id = 'books' 
  AND auth.role() = 'authenticated'
  AND EXISTS (
    SELECT 1 FROM public.users 
    WHERE users.id = auth.uid() 
    AND users.role IN ('admin', 'profesor', 'bibliotecario')
  )
);

-- Permitir eliminación a usuarios autenticados con roles específicos
CREATE POLICY "Allow delete for admins and teachers" ON storage.objects 
FOR DELETE USING (
  bucket_id = 'books' 
  AND auth.role() = 'authenticated'
  AND EXISTS (
    SELECT 1 FROM public.users 
    WHERE users.id = auth.uid() 
    AND users.role IN ('admin', 'profesor', 'bibliotecario')
  )
);

-- 4. Políticas para bucket 'covers'
-- Permitir lectura pública
CREATE POLICY "Public Access Covers" ON storage.objects FOR SELECT USING (bucket_id = 'covers');

-- Permitir subida a usuarios autenticados con roles específicos
CREATE POLICY "Allow upload covers for admins and teachers" ON storage.objects 
FOR INSERT WITH CHECK (
  bucket_id = 'covers' 
  AND auth.role() = 'authenticated'
  AND EXISTS (
    SELECT 1 FROM public.users 
    WHERE users.id = auth.uid() 
    AND users.role IN ('admin', 'profesor', 'bibliotecario')
  )
);

-- Permitir actualización a usuarios autenticados con roles específicos
CREATE POLICY "Allow update covers for admins and teachers" ON storage.objects 
FOR UPDATE USING (
  bucket_id = 'covers' 
  AND auth.role() = 'authenticated'
  AND EXISTS (
    SELECT 1 FROM public.users 
    WHERE users.id = auth.uid() 
    AND users.role IN ('admin', 'profesor', 'bibliotecario')
  )
);

-- Permitir eliminación a usuarios autenticados con roles específicos
CREATE POLICY "Allow delete covers for admins and teachers" ON storage.objects 
FOR DELETE USING (
  bucket_id = 'covers' 
  AND auth.role() = 'authenticated'
  AND EXISTS (
    SELECT 1 FROM public.users 
    WHERE users.id = auth.uid() 
    AND users.role IN ('admin', 'profesor', 'bibliotecario')
  )
);

-- Verificar que los buckets se crearon correctamente
SELECT 'Buckets creados exitosamente' as status;
SELECT name, public, file_size_limit, allowed_mime_types 
FROM storage.buckets 
WHERE name IN ('books', 'covers');
-- Script simplificado para crear buckets de storage
-- Ejecutar paso a paso en SQL Editor de Supabase

-- PASO 1: Verificar si storage está habilitado
SELECT 'Verificando storage...' as status;

-- PASO 2: Verificar buckets existentes (si storage está habilitado)
SELECT name, id, public 
FROM storage.buckets 
WHERE name IN ('books', 'covers');

-- Si el comando anterior falla, significa que storage no está habilitado
-- En ese caso, ve al Dashboard de Supabase y habilita Storage manualmente

-- PASO 3: Crear buckets (solo si storage está habilitado)
-- Ejecutar uno por uno:

INSERT INTO storage.buckets (id, name, public) 
VALUES ('books', 'books', true);

INSERT INTO storage.buckets (id, name, public) 
VALUES ('covers', 'covers', true);

-- PASO 4: Verificar creación
SELECT name, public, created_at 
FROM storage.buckets 
WHERE name IN ('books', 'covers');
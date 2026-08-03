-- Script para exportar schema y datos desde Supabase
-- Ejecutar en el SQL Editor de Supabase

-- 1. Exportar estructura de tablas
\d+ users;
\d+ books;
\d+ videos;
\d+ categories;

-- 2. Generar script de creación
SELECT 
    'CREATE TABLE ' || schemaname||'.'||tablename||' (' || 
    array_to_string(
        array_agg(
            column_name||' '||data_type||
            case when character_maximum_length is not null 
                then '('||character_maximum_length||')' 
                else '' end||
            case when is_nullable = 'NO' then ' NOT NULL' else '' end
        ), 
        ', '
    ) || ');' as create_statement
FROM information_schema.tables t
JOIN information_schema.columns c ON c.table_name = t.tablename
WHERE t.schemaname = 'public' 
  AND t.tablename IN ('users', 'books', 'videos', 'categories')
GROUP BY schemaname, tablename;

-- 3. Exportar datos
COPY users TO '/tmp/users.csv' DELIMITER ',' CSV HEADER;
COPY books TO '/tmp/books.csv' DELIMITER ',' CSV HEADER;
COPY videos TO '/tmp/videos.csv' DELIMITER ',' CSV HEADER;
COPY categories TO '/tmp/categories.csv' DELIMITER ',' CSV HEADER;
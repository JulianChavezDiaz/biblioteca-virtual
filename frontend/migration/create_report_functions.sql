-- Función para obtener estadísticas detalladas de los libros más leídos
-- Ejecutar en el SQL Editor de Supabase

CREATE OR REPLACE FUNCTION get_top_books_detailed()
RETURNS TABLE (
    title TEXT,
    author TEXT,
    category TEXT,
    read_count BIGINT,
    last_read TIMESTAMP WITH TIME ZONE,
    format TEXT,
    created_at TIMESTAMP WITH TIME ZONE
) 
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        b.title,
        b.author,
        b.category,
        COALESCE(bs.open_count, 0) as read_count,
        COALESCE(
            (SELECT boh.created_at 
             FROM book_opens_history boh 
             WHERE boh.book_id = b.id 
             ORDER BY boh.created_at DESC 
             LIMIT 1), 
            b.created_at
        ) as last_read,
        COALESCE(b.format, 'Digital') as format,
        b.created_at
    FROM books b
    LEFT JOIN book_stats bs ON b.id = bs.book_id
    ORDER BY COALESCE(bs.open_count, 0) DESC, b.created_at DESC;
END;
$$;

-- Función alternativa más simple si la anterior no funciona
CREATE OR REPLACE FUNCTION get_library_stats()
RETURNS JSON
LANGUAGE plpgsql
AS $$
DECLARE
    result JSON;
BEGIN
    SELECT json_build_object(
        'total_books', (SELECT COUNT(*) FROM books),
        'total_reads', (SELECT COUNT(*) FROM book_opens_history),
        'top_books', (
            SELECT json_agg(
                json_build_object(
                    'title', b.title,
                    'author', b.author,
                    'category', b.category,
                    'read_count', COALESCE(bs.open_count, 0),
                    'format', COALESCE(b.format, 'Digital'),
                    'created_at', b.created_at
                )
            )
            FROM books b
            LEFT JOIN book_stats bs ON b.id = bs.book_id
            ORDER BY COALESCE(bs.open_count, 0) DESC
            LIMIT 15
        )
    ) INTO result;
    
    RETURN result;
END;
$$;
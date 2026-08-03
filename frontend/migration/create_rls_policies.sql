-- Script para recrear todas las políticas RLS en la cuenta NUEVA
-- Ejecutar en SQL Editor de la cuenta NUEVA

-- 1. Habilitar RLS en todas las tablas
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.books ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.videos ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.favorites ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.reading_history ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.book_stats ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.book_opens_history ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.requests ENABLE ROW LEVEL SECURITY;

-- 2. Políticas para USERS
CREATE POLICY "Allow role check" ON public.users FOR SELECT TO public USING (true);
CREATE POLICY "Users can insert own data" ON public.users FOR INSERT TO public WITH CHECK (auth.uid() = id);
CREATE POLICY "Users can read own data" ON public.users FOR SELECT TO public USING (auth.uid() = id);
CREATE POLICY "Users can update own data" ON public.users FOR UPDATE TO public USING (auth.uid() = id);
CREATE POLICY "Admins can update all users" ON public.users FOR UPDATE TO public USING (
  EXISTS (SELECT 1 FROM users users_1 WHERE users_1.id = auth.uid() AND users_1.role = 'admin'::text)
);

-- 3. Políticas para BOOKS
CREATE POLICY "Anyone can read books" ON public.books FOR SELECT TO public USING (true);
CREATE POLICY "Books are viewable by everyone" ON public.books FOR SELECT TO public USING (true);
CREATE POLICY "Allow admin, profesor and bibliotecario to insert books" ON public.books FOR INSERT TO authenticated WITH CHECK (
  EXISTS (SELECT 1 FROM users WHERE users.id = auth.uid() AND users.role = ANY (ARRAY['admin'::text, 'profesor'::text, 'bibliotecario'::text]))
);
CREATE POLICY "books_insert_policy" ON public.books FOR INSERT TO authenticated WITH CHECK (
  EXISTS (SELECT 1 FROM users WHERE users.id = auth.uid() AND users.role = ANY (ARRAY['admin'::text, 'profesor'::text, 'bibliotecario'::text]))
);
CREATE POLICY "books_update_policy" ON public.books FOR UPDATE TO authenticated USING (
  EXISTS (SELECT 1 FROM users WHERE users.id = auth.uid() AND users.role = ANY (ARRAY['admin'::text, 'profesor'::text, 'bibliotecario'::text]))
);
CREATE POLICY "Books can be deleted by authenticated users" ON public.books FOR DELETE TO public USING (auth.role() = 'authenticated'::text);

-- 4. Políticas para VIDEOS
CREATE POLICY "Anyone can view videos" ON public.videos FOR SELECT TO public USING (true);
CREATE POLICY "Videos are viewable by everyone" ON public.videos FOR SELECT TO public USING (true);
CREATE POLICY "videos_insert_policy" ON public.videos FOR INSERT TO authenticated WITH CHECK (
  EXISTS (SELECT 1 FROM users WHERE users.id = auth.uid() AND users.role = ANY (ARRAY['admin'::text, 'profesor'::text, 'bibliotecario'::text]))
);
CREATE POLICY "videos_update_policy" ON public.videos FOR UPDATE TO authenticated USING (
  EXISTS (SELECT 1 FROM users WHERE users.id = auth.uid() AND users.role = ANY (ARRAY['admin'::text, 'profesor'::text, 'bibliotecario'::text]))
);
CREATE POLICY "Admins can delete videos" ON public.videos FOR DELETE TO public USING (
  EXISTS (SELECT 1 FROM users WHERE users.id = auth.uid() AND users.role = 'admin'::text)
);

-- 5. Políticas para FAVORITES
CREATE POLICY "Users can manage their favorites" ON public.favorites FOR ALL TO public USING (auth.uid() = user_id);
CREATE POLICY "Usuarios agregan favoritos" ON public.favorites FOR INSERT TO public WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Usuarios eliminan favoritos" ON public.favorites FOR DELETE TO public USING (auth.uid() = user_id);
CREATE POLICY "Usuarios ven sus favoritos" ON public.favorites FOR SELECT TO public USING (auth.uid() = user_id);

-- 6. Políticas para READING_HISTORY
CREATE POLICY "Users can manage their history" ON public.reading_history FOR ALL TO public USING (auth.uid() = user_id);

-- 7. Políticas para BOOK_STATS
CREATE POLICY "Todos pueden ver" ON public.book_stats FOR SELECT TO public USING (true);
CREATE POLICY "Sistema puede insertar" ON public.book_stats FOR INSERT TO public WITH CHECK (true);
CREATE POLICY "Sistema puede actualizar" ON public.book_stats FOR UPDATE TO public USING (true);

-- 8. Políticas para BOOK_OPENS_HISTORY
CREATE POLICY "Usuarios ven historial" ON public.book_opens_history FOR SELECT TO public USING (true);
CREATE POLICY "Usuarios registran" ON public.book_opens_history FOR INSERT TO public WITH CHECK (true);

-- Mensaje de confirmación
SELECT 'Todas las políticas RLS han sido creadas exitosamente' as status;
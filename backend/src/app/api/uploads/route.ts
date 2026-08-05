import type { NextRequest } from 'next/server';
import { writeFile, mkdir } from 'fs/promises';
import path from 'path';
import { getAuthUser, hasRole, UPLOAD_ROLES } from '@/lib/auth';
import { ok, fail, withErrors } from '@/lib/http';

export const dynamic = 'force-dynamic';
export const runtime = 'nodejs';

// POST /api/uploads  (multipart, campo "file")
// Reemplaza Supabase Storage. Guarda libros en public/uploads/books y
// portadas en public/uploads/covers. Devuelve una ruta pública portable.
export async function POST(req: NextRequest) {
  return withErrors(async () => {
    const auth = getAuthUser(req);
    if (!auth) return fail('No autenticado', 401);
    if (!hasRole(auth, UPLOAD_ROLES)) return fail('Sin permiso para subir archivos', 403);

    const form = await req.formData();
    const file = form.get('file');
    const folder = form.get('folder');
    
    if (!(file instanceof File)) return fail('Se requiere el campo "file"', 422);

    if (folder !== 'books' && folder !== 'covers') {
      return fail('El campo "folder" debe ser "books" o "covers"', 422);
    }

    const extension = path.extname(file.name).toLowerCase();
    const allowedExtensions =
      folder === 'books'
        ? new Set(['.pdf', '.epub'])
        : new Set(['.jpg', '.jpeg', '.png', '.webp', '.gif']);

    if (!allowedExtensions.has(extension)) {
      return fail(
        folder === 'books'
          ? 'Los libros deben tener extensión PDF o EPUB'
          : 'Las portadas deben ser imágenes JPG, JPEG, PNG, WEBP o GIF',
        422,
      );
    }

    const bytes = Buffer.from(await file.arrayBuffer());
    const filename = `${Date.now()}${extension}`;

    const dir = path.join(process.cwd(), 'public', 'uploads', folder);
    await mkdir(dir, { recursive: true });
    await writeFile(path.join(dir, filename), bytes);

    return ok({ url: `/uploads/${folder}/${filename}` }, 201);
  });
}

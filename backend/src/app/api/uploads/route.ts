import type { NextRequest } from 'next/server';
import { writeFile, mkdir } from 'fs/promises';
import path from 'path';
import { getAuthUser, hasRole, UPLOAD_ROLES } from '@/lib/auth';
import { ok, fail, withErrors } from '@/lib/http';

export const dynamic = 'force-dynamic';
export const runtime = 'nodejs';

// POST /api/uploads  (multipart, campo "file")
// Reemplaza Supabase Storage. Guarda libros en public/uploads/books y
// portadas en public/uploads/covers. Devuelve la URL pública absoluta.
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

    const bytes = Buffer.from(await file.arrayBuffer());
    const safeName = file.name.replace(/[^a-zA-Z0-9._-]/g, '_');
    const filename = `${Date.now()}_${safeName}`;

    const dir = path.join(process.cwd(), 'public', 'uploads', folder);
    await mkdir(dir, { recursive: true });
    await writeFile(path.join(dir, filename), bytes);

    return ok({ url: `${req.nextUrl.origin}/uploads/${folder}/${filename}` }, 201);
  });
}

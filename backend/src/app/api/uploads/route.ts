import type { NextRequest } from 'next/server';
import { writeFile, mkdir } from 'fs/promises';
import path from 'path';
import { getAuthUser, hasRole, UPLOAD_ROLES } from '@/lib/auth';
import { ok, fail, withErrors } from '@/lib/http';

export const dynamic = 'force-dynamic';
export const runtime = 'nodejs';

// POST /api/uploads  (multipart, campo "file")
// Reemplaza Supabase Storage. Guarda en public/uploads y sirve el archivo en
// /uploads/<nombre>. Devuelve { url } absoluto.
export async function POST(req: NextRequest) {
  return withErrors(async () => {
    const auth = getAuthUser(req);
    if (!auth) return fail('No autenticado', 401);
    if (!hasRole(auth, UPLOAD_ROLES)) return fail('Sin permiso para subir archivos', 403);

    const form = await req.formData();
    const file = form.get('file');
    if (!(file instanceof File)) return fail('Se requiere el campo "file"', 422);

    const bytes = Buffer.from(await file.arrayBuffer());
    const safeName = file.name.replace(/[^a-zA-Z0-9._-]/g, '_');
    const filename = `${Date.now()}_${safeName}`;

    const dir = path.join(process.cwd(), 'public', 'uploads');
    await mkdir(dir, { recursive: true });
    await writeFile(path.join(dir, filename), bytes);

    return ok({ url: `${req.nextUrl.origin}/uploads/${filename}` }, 201);
  });
}

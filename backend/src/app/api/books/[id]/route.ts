import type { NextRequest } from 'next/server';
import { prisma } from '@/lib/db';
import { getAuthUser, hasRole, UPLOAD_ROLES, DELETE_ROLES } from '@/lib/auth';
import { ok, fail, withErrors } from '@/lib/http';
import { bookJson } from '@/lib/serializers';

export const dynamic = 'force-dynamic';

type Ctx = { params: Promise<{ id: string }> };

export async function GET(_req: NextRequest, { params }: Ctx) {
  return withErrors(async () => {
    const { id } = await params;
    const book = await prisma.book.findUnique({ where: { id } });
    if (!book) return fail('Libro no encontrado', 404);
    return ok(bookJson(book));
  });
}

export async function PUT(req: NextRequest, { params }: Ctx) {
  return withErrors(async () => {
    const auth = getAuthUser(req);
    if (!auth) return fail('No autenticado', 401);
    if (!hasRole(auth, UPLOAD_ROLES)) return fail('Sin permiso para editar', 403);

    const { id } = await params;
    const b = await req.json().catch(() => ({}));

    const book = await prisma.book.update({
      where: { id },
      data: {
        title: b.title,
        author: b.author,
        description: b.description,
        coverUrl: b.cover_url,
        fileUrl: b.file_url,
        format: b.format,
        categories: Array.isArray(b.categories) ? b.categories : undefined,
        category: b.category,
        subcategory: b.subcategory,
        isbn: b.isbn,
        year: b.year,
        publishedDate: b.published_date ? new Date(b.published_date) : undefined,
        isPhysical: b.is_physical,
        physicalLocation: b.physical_location,
        codigoFisico: b.codigo_fisico,
        isPhysicalOnly: b.is_physical_only,
      },
    });

    return ok(bookJson(book));
  });
}

export async function DELETE(req: NextRequest, { params }: Ctx) {
  return withErrors(async () => {
    const auth = getAuthUser(req);
    if (!auth) return fail('No autenticado', 401);
    if (!hasRole(auth, DELETE_ROLES)) return fail('Sin permiso para borrar', 403);

    const { id } = await params;
    // Soft-delete (igual que la app original): marca deleted_at en vez de borrar.
    await prisma.book.update({ where: { id }, data: { deletedAt: new Date() } });
    return ok({ deleted: true });
  });
}

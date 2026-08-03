import type { NextRequest } from 'next/server';
import { prisma } from '@/lib/db';
import { getAuthUser, hasRole, UPLOAD_ROLES } from '@/lib/auth';
import { ok, fail, withErrors } from '@/lib/http';
import { bookJson } from '@/lib/serializers';

export const dynamic = 'force-dynamic';

// GET /api/books?search=&category=&limit=
export async function GET(req: NextRequest) {
  return withErrors(async () => {
    const { searchParams } = new URL(req.url);
    const search = searchParams.get('search')?.trim();
    const category = searchParams.get('category')?.trim();
    const physical = searchParams.get('physical');
    const limit = Number(searchParams.get('limit')) || undefined;

    const books = await prisma.book.findMany({
      where: {
        deletedAt: null,
        ...(physical ? { isPhysicalOnly: true } : {}),
        AND: [
          category
            ? {
                OR: [
                  { category: { equals: category, mode: 'insensitive' } },
                  { categories: { has: category } },
                ],
              }
            : {},
          search
            ? {
                OR: [
                  { title: { contains: search, mode: 'insensitive' } },
                  { author: { contains: search, mode: 'insensitive' } },
                  { category: { contains: search, mode: 'insensitive' } },
                ],
              }
            : {},
        ],
      },
      orderBy: { createdAt: 'desc' },
      take: limit,
    });

    return ok(books.map(bookJson));
  });
}

// POST /api/books  (crear libro — requiere rol de subida)
export async function POST(req: NextRequest) {
  return withErrors(async () => {
    const auth = getAuthUser(req);
    if (!auth) return fail('No autenticado', 401);
    if (!hasRole(auth, UPLOAD_ROLES)) return fail('Sin permiso para subir libros', 403);

    const b = await req.json().catch(() => null);
    if (!b?.title || !b?.author) return fail('title y author son obligatorios', 422);
    const book = await prisma.book.create({
      data: {
        title: b.title,
        author: b.author,
        description: b.description ?? null,
        coverUrl: b.cover_url ?? null,
        fileUrl: b.file_url ?? null,
        format: b.format ?? null,
        categories: Array.isArray(b.categories) ? b.categories : [],
        category: b.category ?? null,
        subcategory: b.subcategory ?? null,
        isbn: b.isbn ?? null,
        year: b.year ?? null,
        publishedDate: b.published_date ? new Date(b.published_date) : null,
        isPhysical: b.is_physical ?? false,
        physicalLocation: b.physical_location ?? null,
        codigoFisico: b.codigo_fisico ?? null,
        isPhysicalOnly: b.is_physical_only ?? false,
        createdBy: auth.sub,
      },
    });

    return ok(bookJson(book), 201);
  });
}

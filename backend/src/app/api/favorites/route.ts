import type { NextRequest } from 'next/server';
import { prisma } from '@/lib/db';
import { getAuthUser } from '@/lib/auth';
import { ok, fail, withErrors } from '@/lib/http';
import { bookJson } from '@/lib/serializers';

export const dynamic = 'force-dynamic';

// GET /api/favorites          -> ["bookId", ...]
// GET /api/favorites?full=1   -> [ {book...}, ... ]
export async function GET(req: NextRequest) {
  return withErrors(async () => {
    const auth = getAuthUser(req);
    if (!auth) return fail('No autenticado', 401);

    const full = new URL(req.url).searchParams.get('full');

    if (full) {
      const favorites = await prisma.favorite.findMany({
        where: { userId: auth.sub },
        include: { book: true },
        orderBy: { createdAt: 'desc' },
      });
      return ok(favorites.filter((f) => f.book).map((f) => bookJson(f.book)));
    }

    const favorites = await prisma.favorite.findMany({
      where: { userId: auth.sub },
      select: { bookId: true },
      orderBy: { createdAt: 'desc' },
    });
    return ok(favorites.map((f) => f.bookId));
  });
}

// POST /api/favorites { bookId }  (idempotente)
export async function POST(req: NextRequest) {
  return withErrors(async () => {
    const auth = getAuthUser(req);
    if (!auth) return fail('No autenticado', 401);

    const { bookId } = await req.json().catch(() => ({}));
    if (!bookId) return fail('bookId es obligatorio', 422);

    await prisma.favorite.upsert({
      where: { userId_bookId: { userId: auth.sub, bookId } },
      create: { userId: auth.sub, bookId },
      update: {},
    });
    return ok({ favorite: true }, 201);
  });
}

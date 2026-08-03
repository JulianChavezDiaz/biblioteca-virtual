import type { NextRequest } from 'next/server';
import { prisma } from '@/lib/db';
import { getAuthUser } from '@/lib/auth';
import { ok, fail, withErrors } from '@/lib/http';
import { bookJson } from '@/lib/serializers';

export const dynamic = 'force-dynamic';

// GET /api/stats/recent -> [{ book_id, books: {...} }] del usuario actual
export async function GET(req: NextRequest) {
  return withErrors(async () => {
    const auth = getAuthUser(req);
    if (!auth) return fail('No autenticado', 401);

    const history = await prisma.readingHistory.findMany({
      where: { userId: auth.sub },
      include: { book: true },
      orderBy: { lastRead: 'desc' },
      take: 10,
    });

    return ok(
      history.map((h) => ({
        book_id: h.bookId,
        progress: h.progress,
        books: h.book ? bookJson(h.book) : null,
      })),
    );
  });
}

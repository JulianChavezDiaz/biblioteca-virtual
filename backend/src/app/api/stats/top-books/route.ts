import type { NextRequest } from 'next/server';
import { prisma } from '@/lib/db';
import { ok, withErrors } from '@/lib/http';
import { bookJson } from '@/lib/serializers';

export const dynamic = 'force-dynamic';

// GET /api/stats/top-books?limit=15 -> [{ book_id, open_count, books: {...} }]
// Misma forma que devolvía Supabase: book_stats join books.
export async function GET(req: NextRequest) {
  return withErrors(async () => {
    const limit = Math.min(Number(new URL(req.url).searchParams.get('limit')) || 10, 100);
    const stats = await prisma.bookStats.findMany({
      include: { book: true },
      orderBy: { openCount: 'desc' },
      take: limit,
    });

    return ok(
      stats.map((s) => ({
        book_id: s.bookId,
        open_count: s.openCount,
        books: s.book ? bookJson(s.book) : null,
      })),
    );
  });
}

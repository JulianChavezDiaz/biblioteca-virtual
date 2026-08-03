import type { NextRequest } from 'next/server';
import { prisma } from '@/lib/db';
import { getAuthUser } from '@/lib/auth';
import { ok, fail, withErrors } from '@/lib/http';

export const dynamic = 'force-dynamic';

type Ctx = { params: Promise<{ id: string }> };

// POST /api/books/:id/open
// Registra la apertura en el historial e incrementa el contador (book_stats).
// Reemplaza el RPC `increment_book_opens` de Supabase.
export async function POST(req: NextRequest, { params }: Ctx) {
  return withErrors(async () => {
    const auth = getAuthUser(req);
    if (!auth) return fail('No autenticado', 401);

    const { id: bookId } = await params;

    await prisma.$transaction([
      prisma.bookOpenHistory.create({ data: { bookId, userId: auth.sub } }),
      prisma.bookStats.upsert({
        where: { bookId },
        create: { bookId, openCount: 1 },
        update: { openCount: { increment: 1 } },
      }),
    ]);

    return ok({ recorded: true });
  });
}

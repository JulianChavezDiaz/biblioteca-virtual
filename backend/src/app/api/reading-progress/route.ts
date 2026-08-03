import type { NextRequest } from 'next/server';
import { prisma } from '@/lib/db';
import { getAuthUser } from '@/lib/auth';
import { ok, fail, withErrors } from '@/lib/http';

export const dynamic = 'force-dynamic';

// POST /api/reading-progress { bookId, progress }
export async function POST(req: NextRequest) {
  return withErrors(async () => {
    const auth = getAuthUser(req);
    if (!auth) return fail('No autenticado', 401);

    const { bookId, progress } = await req.json().catch(() => ({}));
    if (!bookId) return fail('bookId es obligatorio', 422);

    await prisma.readingHistory.upsert({
      where: { userId_bookId: { userId: auth.sub, bookId } },
      create: { userId: auth.sub, bookId, progress: progress ?? 0, lastRead: new Date() },
      update: { progress: progress ?? 0, lastRead: new Date() },
    });

    return ok({ saved: true });
  });
}

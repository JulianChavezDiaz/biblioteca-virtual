import type { NextRequest } from 'next/server';
import { prisma } from '@/lib/db';
import { getAuthUser } from '@/lib/auth';
import { ok, fail, withErrors } from '@/lib/http';

export const dynamic = 'force-dynamic';

type Ctx = { params: Promise<{ bookId: string }> };

// GET /api/favorites/:bookId -> { isFavorite: boolean }
export async function GET(req: NextRequest, { params }: Ctx) {
  return withErrors(async () => {
    const auth = getAuthUser(req);
    if (!auth) return fail('No autenticado', 401);

    const { bookId } = await params;
    const found = await prisma.favorite.findUnique({
      where: { userId_bookId: { userId: auth.sub, bookId } },
    });
    return ok({ isFavorite: !!found });
  });
}

// DELETE /api/favorites/:bookId
export async function DELETE(req: NextRequest, { params }: Ctx) {
  return withErrors(async () => {
    const auth = getAuthUser(req);
    if (!auth) return fail('No autenticado', 401);

    const { bookId } = await params;
    await prisma.favorite.deleteMany({ where: { userId: auth.sub, bookId } });
    return ok({ favorite: false });
  });
}

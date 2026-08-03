import type { NextRequest } from 'next/server';
import { prisma } from '@/lib/db';
import { getAuthUser, hasRole, DELETE_ROLES } from '@/lib/auth';
import { ok, fail, withErrors } from '@/lib/http';
import { userJson } from '@/lib/serializers';

export const dynamic = 'force-dynamic';

// GET /api/users  (gestión — solo staff)
export async function GET(req: NextRequest) {
  return withErrors(async () => {
    const auth = getAuthUser(req);
    if (!auth) return fail('No autenticado', 401);
    if (!hasRole(auth, DELETE_ROLES)) return fail('Sin permiso', 403);

    const users = await prisma.user.findMany({ orderBy: { createdAt: 'desc' } });
    return ok(users.map(userJson));
  });
}

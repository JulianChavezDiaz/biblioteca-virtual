import type { NextRequest } from 'next/server';
import { prisma } from '@/lib/db';
import { getAuthUser, hasRole, DELETE_ROLES } from '@/lib/auth';
import { ok, fail, withErrors } from '@/lib/http';
import { supportRequestJson } from '@/lib/serializers';

export const dynamic = 'force-dynamic';

// GET /api/support-requests
//   - admin/bibliotecario: ven todas
//   - resto: solo las suyas
export async function GET(req: NextRequest) {
  return withErrors(async () => {
    const auth = getAuthUser(req);
    if (!auth) return fail('No autenticado', 401);

    const seeAll = hasRole(auth, DELETE_ROLES);
    const requests = await prisma.supportRequest.findMany({
      where: seeAll ? {} : { userId: auth.sub },
      include: { user: { select: { name: true, email: true } } },
      orderBy: { createdAt: 'desc' },
    });

    return ok(requests.map(supportRequestJson));
  });
}

// POST /api/support-requests { title, description, type }
export async function POST(req: NextRequest) {
  return withErrors(async () => {
    const auth = getAuthUser(req);
    if (!auth) return fail('No autenticado', 401);

    const b = await req.json().catch(() => null);
    if (!b?.title || !b?.description || !b?.type) {
      return fail('title, description y type son obligatorios', 422);
    }

    const request = await prisma.supportRequest.create({
      data: {
        userId: auth.sub,
        title: b.title,
        description: b.description,
        type: b.type,
        status: 'pendiente',
      },
      include: { user: { select: { name: true, email: true } } },
    });

    return ok(supportRequestJson(request), 201);
  });
}

import type { NextRequest } from 'next/server';
import { prisma } from '@/lib/db';
import { getAuthUser, hasRole, DELETE_ROLES } from '@/lib/auth';
import { ok, fail, withErrors } from '@/lib/http';
import { supportRequestJson } from '@/lib/serializers';

export const dynamic = 'force-dynamic';

type Ctx = { params: Promise<{ id: string }> };

// PATCH /api/support-requests/:id  -> marca como resuelto (solo staff)
export async function PATCH(req: NextRequest, { params }: Ctx) {
  return withErrors(async () => {
    const auth = getAuthUser(req);
    if (!auth) return fail('No autenticado', 401);
    if (!hasRole(auth, DELETE_ROLES)) return fail('Sin permiso', 403);

    const { id } = await params;
    const request = await prisma.supportRequest.update({
      where: { id },
      data: { status: 'resuelto', resolvedAt: new Date() },
      include: { user: { select: { name: true, email: true } } },
    });
    return ok(supportRequestJson(request));
  });
}

// DELETE /api/support-requests/:id  (dueño o staff)
export async function DELETE(req: NextRequest, { params }: Ctx) {
  return withErrors(async () => {
    const auth = getAuthUser(req);
    if (!auth) return fail('No autenticado', 401);

    const { id } = await params;
    const existing = await prisma.supportRequest.findUnique({ where: { id } });
    if (!existing) return fail('No encontrado', 404);
    if (existing.userId !== auth.sub && !hasRole(auth, DELETE_ROLES)) {
      return fail('Sin permiso', 403);
    }

    await prisma.supportRequest.delete({ where: { id } });
    return ok({ deleted: true });
  });
}

import type { NextRequest } from 'next/server';
import { prisma } from '@/lib/db';
import { getAuthUser, hasRole, UPLOAD_ROLES, DELETE_ROLES } from '@/lib/auth';
import { ok, fail, withErrors } from '@/lib/http';
import { categoryJson } from '@/lib/serializers';

export const dynamic = 'force-dynamic';

type Ctx = { params: Promise<{ id: string }> };

export async function PUT(req: NextRequest, { params }: Ctx) {
  return withErrors(async () => {
    const auth = getAuthUser(req);
    if (!auth) return fail('No autenticado', 401);
    if (!hasRole(auth, UPLOAD_ROLES)) return fail('Sin permiso', 403);

    const { id } = await params;
    const c = await req.json().catch(() => ({}));
    if (!c?.name?.trim()) return fail('El nombre es obligatorio', 422);

    const category = await prisma.category.update({
      where: { id },
      data: { name: c.name.trim(), description: c.description?.trim() ?? null },
    });
    return ok(categoryJson(category));
  });
}

// Borrado lógico (is_active = false), igual que la app actual.
export async function DELETE(req: NextRequest, { params }: Ctx) {
  return withErrors(async () => {
    const auth = getAuthUser(req);
    if (!auth) return fail('No autenticado', 401);
    if (!hasRole(auth, DELETE_ROLES)) return fail('Sin permiso', 403);

    const { id } = await params;
    await prisma.category.update({ where: { id }, data: { isActive: false } });
    return ok({ deleted: true });
  });
}

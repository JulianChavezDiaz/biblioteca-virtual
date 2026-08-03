import type { NextRequest } from 'next/server';
import { prisma } from '@/lib/db';
import { getAuthUser, hasRole, UPLOAD_ROLES } from '@/lib/auth';
import { ok, fail, withErrors } from '@/lib/http';
import { categoryJson } from '@/lib/serializers';

export const dynamic = 'force-dynamic';

// GET /api/categories  (solo activas)
export async function GET() {
  return withErrors(async () => {
    const categories = await prisma.category.findMany({
      where: { isActive: true },
      orderBy: { name: 'asc' },
    });
    return ok(categories.map(categoryJson));
  });
}

// POST /api/categories
export async function POST(req: NextRequest) {
  return withErrors(async () => {
    const auth = getAuthUser(req);
    if (!auth) return fail('No autenticado', 401);
    if (!hasRole(auth, UPLOAD_ROLES)) return fail('Sin permiso', 403);

    const c = await req.json().catch(() => null);
    if (!c?.name?.trim()) return fail('El nombre es obligatorio', 422);

    const category = await prisma.category.create({
      data: {
        name: c.name.trim(),
        description: c.description?.trim() ?? null,
        createdBy: auth.sub,
      },
    });

    return ok(categoryJson(category), 201);
  });
}

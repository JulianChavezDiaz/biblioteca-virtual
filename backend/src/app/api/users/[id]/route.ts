import type { NextRequest } from 'next/server';
import { prisma } from '@/lib/db';
import { getAuthUser, hasRole, ADMIN_ROLES, hashPassword } from '@/lib/auth';
import { ok, fail, withErrors } from '@/lib/http';
import { userJson } from '@/lib/serializers';

export const dynamic = 'force-dynamic';

type Ctx = { params: Promise<{ id: string }> };

const VALID_ROLES = ['admin', 'bibliotecario', 'profesor', 'lector', 'user'];

// GET /api/users/:id -> info básica { id, name, role } (cualquier usuario autenticado).
// Usado por "creado por" en el detalle del libro.
export async function GET(req: NextRequest, { params }: Ctx) {
  return withErrors(async () => {
    const auth = getAuthUser(req);
    if (!auth) return fail('No autenticado', 401);

    const { id } = await params;
    const user = await prisma.user.findUnique({
      where: { id },
      select: { id: true, name: true, role: true },
    });
    if (!user) return fail('Usuario no encontrado', 404);
    return ok(user);
  });
}

// PATCH /api/users/:id { name?, role?, password? }  -> actualizar (solo admin)
export async function PATCH(req: NextRequest, { params }: Ctx) {
  return withErrors(async () => {
    const auth = getAuthUser(req);
    if (!auth) return fail('No autenticado', 401);
    if (!hasRole(auth, ADMIN_ROLES)) return fail('Solo admin', 403);

    const { id } = await params;
    const body = await req.json().catch(() => ({}));

    const data: { name?: string; role?: string; passwordHash?: string } = {};

    if (typeof body.name === 'string' && body.name.trim()) {
      data.name = body.name.trim();
    }
    if (typeof body.role === 'string') {
      if (!VALID_ROLES.includes(body.role)) return fail('Rol inválido', 422);
      data.role = body.role;
    }
    if (typeof body.password === 'string' && body.password) {
      if (body.password.length < 6) {
        return fail('La contraseña debe tener al menos 6 caracteres', 422);
      }
      data.passwordHash = await hashPassword(body.password);
    }

    if (Object.keys(data).length === 0) return fail('Nada que actualizar', 422);

    const user = await prisma.user.update({ where: { id }, data });
    return ok(userJson(user));
  });
}

// DELETE /api/users/:id  (solo admin)
export async function DELETE(req: NextRequest, { params }: Ctx) {
  return withErrors(async () => {
    const auth = getAuthUser(req);
    if (!auth) return fail('No autenticado', 401);
    if (!hasRole(auth, ADMIN_ROLES)) return fail('Solo admin', 403);

    const { id } = await params;
    if (id === auth.sub) return fail('No puedes eliminar tu propia cuenta', 400);

    await prisma.user.delete({ where: { id } });
    return ok({ deleted: true });
  });
}

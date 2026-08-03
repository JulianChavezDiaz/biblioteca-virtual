import type { NextRequest } from 'next/server';
import { prisma } from '@/lib/db';
import { getAuthUser, hashPassword } from '@/lib/auth';
import { ok, fail, withErrors } from '@/lib/http';
import { userJson } from '@/lib/serializers';

export const dynamic = 'force-dynamic';

// Devuelve el usuario autenticado a partir del token (para restaurar sesión).
export async function GET(req: NextRequest) {
  return withErrors(async () => {
    const auth = getAuthUser(req);
    if (!auth) return fail('No autenticado', 401);

    const user = await prisma.user.findUnique({ where: { id: auth.sub } });
    if (!user) return fail('Usuario no encontrado', 404);
    return ok({ user: userJson(user) });
  });
}

// PATCH /api/auth/me { name?, password? } -> el usuario actualiza su propio perfil.
export async function PATCH(req: NextRequest) {
  return withErrors(async () => {
    const auth = getAuthUser(req);
    if (!auth) return fail('No autenticado', 401);

    const body = await req.json().catch(() => ({}));
    const data: { name?: string; passwordHash?: string } = {};

    if (typeof body.name === 'string' && body.name.trim()) {
      data.name = body.name.trim();
    }
    if (typeof body.password === 'string' && body.password) {
      if (body.password.length < 6) {
        return fail('La contraseña debe tener al menos 6 caracteres', 422);
      }
      data.passwordHash = await hashPassword(body.password);
    }

    if (Object.keys(data).length === 0) return fail('Nada que actualizar', 422);

    const user = await prisma.user.update({ where: { id: auth.sub }, data });
    return ok({ user: userJson(user) });
  });
}

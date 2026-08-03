import type { NextRequest } from 'next/server';
import { z } from 'zod';
import { prisma } from '@/lib/db';
import { verifyPassword, signToken } from '@/lib/auth';
import { ok, fail, withErrors } from '@/lib/http';
import { userJson } from '@/lib/serializers';

export const dynamic = 'force-dynamic';

const schema = z.object({
  email: z.string().email(),
  password: z.string().min(1),
});

export async function POST(req: NextRequest) {
  return withErrors(async () => {
    const body = await req.json().catch(() => null);
    const parsed = schema.safeParse(body);
    if (!parsed.success) return fail('Email o contraseña inválidos', 422);

    const { email, password } = parsed.data;
    const user = await prisma.user.findUnique({ where: { email } });
    if (!user || !user.passwordHash) {
      return fail('Credenciales incorrectas', 401);
    }
    if (!(await verifyPassword(password, user.passwordHash))) {
      return fail('Credenciales incorrectas', 401);
    }

    const token = signToken({ sub: user.id, email: user.email, name: user.name, role: user.role });
    return ok({ token, user: userJson(user) });
  });
}

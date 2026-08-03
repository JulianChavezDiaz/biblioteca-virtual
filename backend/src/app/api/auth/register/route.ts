import type { NextRequest } from 'next/server';
import { z } from 'zod';
import { prisma } from '@/lib/db';
import { hashPassword, signToken } from '@/lib/auth';
import { ok, fail, withErrors } from '@/lib/http';
import { userJson } from '@/lib/serializers';

export const dynamic = 'force-dynamic';

const schema = z.object({
  email: z.string().email(),
  password: z.string().min(6, 'La contraseña debe tener al menos 6 caracteres'),
  name: z.string().min(1),
});

export async function POST(req: NextRequest) {
  return withErrors(async () => {
    const body = await req.json().catch(() => null);
    const parsed = schema.safeParse(body);
    if (!parsed.success) {
      return fail(parsed.error.issues[0]?.message ?? 'Datos inválidos', 422);
    }
    const { email, password, name } = parsed.data;

    const existing = await prisma.user.findUnique({ where: { email } });
    if (existing) return fail('El email ya está registrado', 409);

    const user = await prisma.user.create({
      data: {
        email,
        name,
        passwordHash: await hashPassword(password),
        role: 'lector',
      },
    });

    const token = signToken({ sub: user.id, email: user.email, name: user.name, role: user.role });
    return ok({ token, user: userJson(user) }, 201);
  });
}
